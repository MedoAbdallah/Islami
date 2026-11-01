import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/watch_compass_heading.dart';
import 'qibla_compass_state.dart';

class QiblaCompassCubit extends Cubit<QiblaCompassState> {
  QiblaCompassCubit(
    this._watchHeading, {
    required this.latitude,
    required this.longitude,
  }) : super(const QiblaCompassState());

  final WatchCompassHeading _watchHeading;
  final double latitude;
  final double longitude;
  StreamSubscription<double?>? _subscription;

  void start() {
    _subscription ??= _watchHeading(
      latitude: latitude,
      longitude: longitude,
    )?.listen(
      (heading) => emit(QiblaCompassState(heading: heading)),
      onError: (Object error) {
        emit(const QiblaCompassState());
        debugPrint('Qibla compass sensor is unavailable: $error');
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
