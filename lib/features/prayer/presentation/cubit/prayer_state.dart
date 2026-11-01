import 'package:adhan/adhan.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/prayer_models.dart';

class PrayerState extends Equatable {
  static const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const defaultNotificationSettings = <String, bool>{
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  const PrayerState({
    required this.coordinates,
    required this.now,
    this.today = const [],
    this.tomorrow = const [],
    this.next,
    this.current,
    this.remaining = Duration.zero,
    this.useGps = true,
    this.cityId,
    this.locationLabel = 'جارٍ تحديد الموقع',
    this.locationError,
    this.isLoading = false,
    this.loadError,
    this.isAdhanMuted = false,
    this.adhanReciter = 'mansour',
    this.prayerNotificationsEnabled = true,
    this.notificationSoundEnabled = true,
    this.enabledPrayerNotifications = defaultNotificationSettings,
    this.prayerOffsets = const {
      'Fajr': 0,
      'Dhuhr': 0,
      'Asr': 0,
      'Maghrib': 0,
      'Isha': 0,
    },
    this.exactAlarmPermissionGranted = false,
    this.notificationPermissionGranted = false,
  });

  final Coordinates coordinates;
  final DateTime now;
  final List<PrayerInfo> today;
  final List<PrayerInfo> tomorrow;
  final PrayerInfo? next;
  final PrayerInfo? current;
  final Duration remaining;
  final bool useGps;
  final String? cityId;
  final String locationLabel;
  final PrayerLocationException? locationError;
  final bool isLoading;
  final String? loadError;
  final bool isAdhanMuted;
  final String adhanReciter;
  final bool prayerNotificationsEnabled;
  final bool notificationSoundEnabled;
  final Map<String, bool> enabledPrayerNotifications;
  final Map<String, int> prayerOffsets;
  final bool exactAlarmPermissionGranted;
  final bool notificationPermissionGranted;
  PrayerInfo? get tomorrowFajr => tomorrow.isEmpty ? null : tomorrow.first;

  PrayerState copyWith({
    Coordinates? coordinates,
    DateTime? now,
    List<PrayerInfo>? today,
    List<PrayerInfo>? tomorrow,
    PrayerInfo? next,
    PrayerInfo? current,
    Duration? remaining,
    bool? useGps,
    String? cityId,
    String? locationLabel,
    PrayerLocationException? locationError,
    bool? isLoading,
    String? loadError,
    bool? isAdhanMuted,
    String? adhanReciter,
    bool? prayerNotificationsEnabled,
    bool? notificationSoundEnabled,
    Map<String, bool>? enabledPrayerNotifications,
    Map<String, int>? prayerOffsets,
    bool? exactAlarmPermissionGranted,
    bool? notificationPermissionGranted,
    bool clearErrors = false,
    bool clearCityId = false,
  }) => PrayerState(
    coordinates: coordinates ?? this.coordinates,
    now: now ?? this.now,
    today: today ?? this.today,
    tomorrow: tomorrow ?? this.tomorrow,
    next: next ?? this.next,
    current: current ?? this.current,
    remaining: remaining ?? this.remaining,
    useGps: useGps ?? this.useGps,
    cityId: clearCityId ? null : cityId ?? this.cityId,
    locationLabel: locationLabel ?? this.locationLabel,
    locationError: clearErrors ? null : locationError ?? this.locationError,
    isLoading: isLoading ?? this.isLoading,
    loadError: clearErrors ? null : loadError ?? this.loadError,
    isAdhanMuted: isAdhanMuted ?? this.isAdhanMuted,
    adhanReciter: adhanReciter ?? this.adhanReciter,
    prayerNotificationsEnabled:
        prayerNotificationsEnabled ?? this.prayerNotificationsEnabled,
    notificationSoundEnabled:
        notificationSoundEnabled ?? this.notificationSoundEnabled,
    enabledPrayerNotifications:
        enabledPrayerNotifications ?? this.enabledPrayerNotifications,
    prayerOffsets: prayerOffsets ?? this.prayerOffsets,
    exactAlarmPermissionGranted:
        exactAlarmPermissionGranted ?? this.exactAlarmPermissionGranted,
    notificationPermissionGranted:
        notificationPermissionGranted ?? this.notificationPermissionGranted,
  );

  @override
  List<Object?> get props => [
    coordinates,
    now,
    today,
    tomorrow,
    next,
    current,
    remaining,
    useGps,
    cityId,
    locationLabel,
    locationError,
    isLoading,
    loadError,
    isAdhanMuted,
    adhanReciter,
    prayerNotificationsEnabled,
    notificationSoundEnabled,
    enabledPrayerNotifications,
    prayerOffsets,
    exactAlarmPermissionGranted,
    notificationPermissionGranted,
  ];
}
