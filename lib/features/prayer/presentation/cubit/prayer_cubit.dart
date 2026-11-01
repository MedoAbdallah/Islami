import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:islami/features/prayer/data/datasources/adhan_data_source.dart';
import 'package:islami/features/prayer/data/datasources/prayer_notification_service.dart';
import 'package:islami/features/prayer/data/datasources/prayer_time_adjustment_store.dart';
import '../../domain/entities/prayer_models.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../../domain/usecases/get_prayer_times.dart';
import 'prayer_state.dart';

class PrayerCubit extends Cubit<PrayerState> with WidgetsBindingObserver {
  PrayerCubit(this._repository)
    : super(PrayerState(coordinates: _repository.cairo, now: DateTime.now()));
  final PrayerRepository _repository;
  final PrayerTimeAdjustmentStore _adjustmentStore =
      PrayerTimeAdjustmentStore();
  late final GetPrayerTimes _getPrayerTimes = GetPrayerTimes(_repository);
  Timer? _timer;
  bool _appIsResumed = true;
  Coordinates get coordinates => state.coordinates;
  DateTime get now => state.now;
  List<PrayerInfo> get today => state.today;
  List<PrayerInfo> get tomorrow => state.tomorrow;
  PrayerInfo? get next => state.next;
  PrayerInfo? get current => state.current;
  Duration get remaining => state.remaining;
  bool get useGps => state.useGps;
  String? get cityId => state.cityId;
  String get locationLabel => state.locationLabel;
  PrayerLocationException? get locationError => state.locationError;
  bool get isLoading => state.isLoading;
  String? get loadError => state.loadError;
  List<CityOption> get popularCities => _repository.popularCities;
  Map<int, String> get methodLabels => _repository.methodLabels;
  Map<String, String> get reciters => AdhanService.reciters;
  Future<int> getMethod() => _repository.getMethod();
  Future<int> getSchool() => _repository.getSchool();
  Future<void> requestNotificationPermissions() async {
    final result = await PrayerNotificationService.instance
        .requestPermissions();
    if (!isClosed) {
      emit(
        state.copyWith(
          notificationPermissionGranted: result.notifications,
          exactAlarmPermissionGranted: result.exactAlarms,
        ),
      );
    }
    await _refreshNotifications(state.today, state.tomorrow);
  }

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    final today = _repository.timesFor(state.coordinates, now);
    emit(_withNextAndCurrent(state.copyWith(now: now, today: today)));
    await _initializeAlerts();
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    await loadPrayerTimes();
  }

  Future<void> _initializeAlerts() async {
    await AdhanService.instance.initialize();
    await PrayerNotificationService.instance.initialize();
    final notifications = await PrayerNotificationService.instance
        .loadSettings();
    final offsets = await _adjustmentStore.load();
    final exactAllowed = await PrayerNotificationService.instance
        .canScheduleExactly();
    final notificationsAllowed = await PrayerNotificationService.instance
        .canReceiveNotifications();
    if (!isClosed) {
      emit(
        _withNextAndCurrent(
          state.copyWith(
            isAdhanMuted: AdhanService.instance.isMuted,
            adhanReciter: AdhanService.instance.reciter,
            prayerNotificationsEnabled: notifications.enabled,
            notificationSoundEnabled: notifications.soundEnabled,
            enabledPrayerNotifications: notifications.prayers,
            prayerOffsets: offsets,
            exactAlarmPermissionGranted: exactAllowed,
            notificationPermissionGranted: notificationsAllowed,
            today: _applyOffsets(state.today, offsets: offsets),
            tomorrow: _applyOffsets(state.tomorrow, offsets: offsets),
          ),
        ),
      );
    }
  }

  Future<void> loadPrayerTimes() async {
    if (state.isLoading || isClosed) return;
    emit(state.copyWith(isLoading: true, clearErrors: true));
    try {
      final useGps = await _repository.getUseGps();
      final cityId = await _repository.getSavedCityId();
      final found = await _repository.getCoordinates();
      if (isClosed) return;
      final city = _repository.cityById(cityId);
      final locationLabel = !useGps && city != null
          ? city.nameAr
          : (_isCairo(found) ? 'القاهرة' : 'موقعك الحالي');
      final fetching = DateTime.now();
      emit(
        state.copyWith(
          coordinates: found,
          useGps: useGps,
          cityId: cityId,
          locationLabel: locationLabel,
          now: fetching,
        ),
      );
      final today = _applyOffsets(await _getPrayerTimes(found, fetching));
      final tomorrow = _applyOffsets(
        await _getPrayerTimes(found, fetching.add(const Duration(days: 1))),
      );
      if (isClosed) return;
      final updated = _withNextAndCurrent(
        state.copyWith(now: fetching, today: today, tomorrow: tomorrow),
      );
      emit(updated);
      await _refreshNotifications(today, tomorrow);
    } catch (error, stack) {
      debugPrint('Could not load prayer times: $error');
      debugPrintStack(stackTrace: stack);
      if (isClosed) return;
      final locationError = error is PrayerLocationException ? error : null;
      var updated = state.copyWith(
        locationError: locationError,
        loadError:
            locationError?.message ??
            'تعذر تحديث المواقيت. يتم عرض المواقيت المحسوبة محليًا.',
        locationLabel: locationError != null && state.useGps
            ? 'الموقع غير متاح'
            : state.locationLabel,
      );
      if (updated.today.isEmpty)
        updated = updated.copyWith(
          today: _applyOffsets(
            _repository.timesFor(updated.coordinates, updated.now),
          ),
        );
      emit(_withNextAndCurrent(updated));
    } finally {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> setLocation({required bool gps, String? selectedCityId}) async {
    await _repository.setUseGps(gps);
    await _repository.setSavedCityId(gps ? null : selectedCityId);
    emit(state.copyWith(useGps: gps, cityId: selectedCityId, clearCityId: gps));
    await loadPrayerTimes();
  }

  Future<void> saveCalculation({
    required int method,
    required int school,
  }) async {
    await _repository.setMethod(method);
    await _repository.setSchool(school);
    await loadPrayerTimes();
  }

  Future<void> toggleMute() async {
    await AdhanService.instance.toggleMuted();
    if (!isClosed)
      emit(state.copyWith(isAdhanMuted: AdhanService.instance.isMuted));
    await _refreshNotifications(state.today, state.tomorrow);
  }

  Future<void> setReciter(String value) async {
    await AdhanService.instance.setReciter(value);
    if (!isClosed)
      emit(state.copyWith(adhanReciter: AdhanService.instance.reciter));
    await _refreshNotifications(state.today, state.tomorrow);
  }

  Future<void> setPrayerNotificationsEnabled(bool enabled) async {
    await PrayerNotificationService.instance.saveEnabled(enabled);
    if (!isClosed) emit(state.copyWith(prayerNotificationsEnabled: enabled));
    await _refreshNotifications(state.today, state.tomorrow);
  }

  Future<void> setPrayerNotificationEnabled(String prayer, bool enabled) async {
    if (!PrayerState.prayerNames.contains(prayer)) return;
    await PrayerNotificationService.instance.savePrayerEnabled(prayer, enabled);
    final settings = Map<String, bool>.from(state.enabledPrayerNotifications)
      ..[prayer] = enabled;
    if (!isClosed) emit(state.copyWith(enabledPrayerNotifications: settings));
    await _refreshNotifications(state.today, state.tomorrow);
  }

  Future<void> setNotificationSoundEnabled(bool enabled) async {
    await PrayerNotificationService.instance.saveSoundEnabled(enabled);
    if (!isClosed) emit(state.copyWith(notificationSoundEnabled: enabled));
    await _refreshNotifications(state.today, state.tomorrow);
  }

  Future<void> adjustPrayerOffset(String prayer, int changeInMinutes) async {
    if (!PrayerState.prayerNames.contains(prayer) || changeInMinutes == 0)
      return;
    final offsets = Map<String, int>.from(state.prayerOffsets);
    final updatedOffset = ((offsets[prayer] ?? 0) + changeInMinutes)
        .clamp(-180, 180)
        .toInt();
    final appliedChange = updatedOffset - (offsets[prayer] ?? 0);
    if (appliedChange == 0) return;
    offsets[prayer] = updatedOffset;
    await _adjustmentStore.save(prayer, updatedOffset);
    final today = _shiftPrayer(state.today, prayer, appliedChange);
    final tomorrow = _shiftPrayer(state.tomorrow, prayer, appliedChange);
    if (!isClosed) {
      emit(
        _withNextAndCurrent(
          state.copyWith(
            today: today,
            tomorrow: tomorrow,
            prayerOffsets: offsets,
          ),
        ),
      );
    }
    await _refreshNotifications(state.today, state.tomorrow);
  }

  Future<void> resetPrayerOffset(String prayer) async {
    final current = state.prayerOffsets[prayer] ?? 0;
    if (current != 0) await adjustPrayerOffset(prayer, -current);
  }

  Future<void> playAdhanPreview() => AdhanService.instance.playPreview();

  Future<void> _refreshNotifications(
    List<PrayerInfo> day,
    List<PrayerInfo> nextDay,
  ) async {
    await AdhanService.instance.initialize();
    final method = await _repository.getMethod();
    final school = await _repository.getSchool();
    final prayers = <(String, DateTime)>[
      ...day.map((p) => (p.name, p.time)),
      ...nextDay.map((p) => (p.name, p.time)),
    ];
    for (var offset = 2; offset < 7; offset++) {
      prayers.addAll(
        _applyOffsets(
          _repository.timesFor(
            state.coordinates,
            DateTime.now().add(Duration(days: offset)),
            method: method,
            school: school,
          ),
        ).map((p) => (p.name, p.time)),
      );
    }
    await PrayerNotificationService.instance.refresh(
      prayers,
      enabled: state.prayerNotificationsEnabled,
      enabledPrayers: state.enabledPrayerNotifications,
      soundEnabled: state.notificationSoundEnabled,
      reciter: state.adhanReciter,
    );
  }

  List<PrayerInfo> _applyOffsets(
    List<PrayerInfo> prayers, {
    Map<String, int>? offsets,
  }) => [
    for (final prayer in prayers)
      PrayerInfo(
        prayer.name,
        prayer.time.add(
          Duration(minutes: (offsets ?? state.prayerOffsets)[prayer.name] ?? 0),
        ),
      ),
  ];

  List<PrayerInfo> _shiftPrayer(
    List<PrayerInfo> prayers,
    String prayerName,
    int minutes,
  ) => [
    for (final prayer in prayers)
      PrayerInfo(
        prayer.name,
        prayer.name == prayerName
            ? prayer.time.add(Duration(minutes: minutes))
            : prayer.time,
      ),
  ];

  void _tick() {
    if (isClosed) return;
    final currentTime = DateTime.now();
    for (final prayer in [...state.today, ...state.tomorrow]) {
      if (prayer.time.isAfter(state.now) && !prayer.time.isAfter(currentTime)) {
        final key =
            '${prayer.time.year}-${prayer.time.month}-${prayer.time.day}-${prayer.name}';
        final scheduledAlertPlaysSound =
            state.prayerNotificationsEnabled &&
            state.notificationSoundEnabled &&
            state.enabledPrayerNotifications[prayer.name] == true;
        if (_appIsResumed && !state.isAdhanMuted && !scheduledAlertPlaysSound) {
          unawaited(AdhanService.instance.playAtPrayer(PrayerKey(key)));
        }
      }
    }
    final dayChanged =
        currentTime.year != state.now.year ||
        currentTime.month != state.now.month ||
        currentTime.day != state.now.day;
    emit(_withNextAndCurrent(state.copyWith(now: currentTime)));
    if (dayChanged) unawaited(loadPrayerTimes());
  }

  PrayerState _withNextAndCurrent(PrayerState source) {
    PrayerInfo? next;
    PrayerInfo? current;
    for (var i = 0; i < source.today.length; i++) {
      if (source.today[i].time.isAfter(source.now)) {
        next = source.today[i];
        if (i > 0) current = source.today[i - 1];
        break;
      }
    }
    if (next == null) {
      current = source.today.isEmpty ? null : source.today.last;
      next = source.tomorrowFajr;
    }
    if (source.today.isNotEmpty && source.now.isBefore(source.today.first.time))
      current = null;
    next ??= source.today.isEmpty
        ? PrayerInfo('Fajr', source.now.add(const Duration(hours: 1)))
        : source.today.first;
    var remaining = next.time.difference(source.now);
    if (remaining.isNegative) remaining = Duration.zero;
    return PrayerState(
      coordinates: source.coordinates,
      now: source.now,
      today: source.today,
      tomorrow: source.tomorrow,
      next: next,
      current: current,
      remaining: remaining,
      useGps: source.useGps,
      cityId: source.cityId,
      locationLabel: source.locationLabel,
      locationError: source.locationError,
      isLoading: source.isLoading,
      loadError: source.loadError,
      isAdhanMuted: source.isAdhanMuted,
      adhanReciter: source.adhanReciter,
      prayerNotificationsEnabled: source.prayerNotificationsEnabled,
      notificationSoundEnabled: source.notificationSoundEnabled,
      enabledPrayerNotifications: source.enabledPrayerNotifications,
      prayerOffsets: source.prayerOffsets,
      exactAlarmPermissionGranted: source.exactAlarmPermissionGranted,
      notificationPermissionGranted: source.notificationPermissionGranted,
    );
  }

  bool _isCairo(Coordinates value) =>
      (value.latitude - _repository.cairo.latitude).abs() < .01 &&
      (value.longitude - _repository.cairo.longitude).abs() < .01;

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    _appIsResumed = lifecycleState == AppLifecycleState.resumed;
    if (isClosed) return;
    final currentTime = DateTime.now();
    final dayChanged =
        currentTime.year != state.now.year ||
        currentTime.month != state.now.month ||
        currentTime.day != state.now.day;
    emit(_withNextAndCurrent(state.copyWith(now: currentTime)));
    if (_appIsResumed && dayChanged) unawaited(loadPrayerTimes());
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    await super.close();
  }
}
