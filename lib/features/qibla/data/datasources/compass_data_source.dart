import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassDataSource {
  static const _platform = MethodChannel('islami/qibla');

  Stream<double?>? headings({
    required double latitude,
    required double longitude,
  }) {
    final events = FlutterCompass.events;
    if (events == null) return null;

    final declination = _magneticDeclination(latitude, longitude);
    return events.asyncMap((event) async {
      final magneticHeading = event.heading;
      if (magneticHeading == null ||
          !magneticHeading.isFinite ||
          magneticHeading < 0 ||
          magneticHeading >= 360) {
        return null;
      }

      // Android reports a magnetic heading. Convert it to true north so it
      // can be compared to the geographic Qibla bearing. iOS already supplies
      // true heading through CLLocationManager.
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _normalize(magneticHeading + await declination);
      }
      return magneticHeading;
    });
  }

  Future<double> _magneticDeclination(double latitude, double longitude) async {
    if (defaultTargetPlatform != TargetPlatform.android) return 0;
    try {
      final value = await _platform.invokeMethod<num>(
        'magneticDeclination',
        {'latitude': latitude, 'longitude': longitude},
      );
      return value?.toDouble() ?? 0;
    } on PlatformException catch (error) {
      debugPrint('Could not calculate magnetic declination: $error');
      return 0;
    } on MissingPluginException catch (error) {
      debugPrint('Magnetic declination channel is unavailable: $error');
      return 0;
    }
  }

  double _normalize(double degrees) => (degrees % 360 + 360) % 360;
}
