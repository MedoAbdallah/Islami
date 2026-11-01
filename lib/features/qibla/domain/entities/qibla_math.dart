import 'dart:math' as math;

/// Shared, local-only Qibla geometry. Coordinates are latitude/longitude.
class QiblaMath {
  QiblaMath._();

  static const kaabaLatitude = 21.4225;
  static const kaabaLongitude = 39.8262;
  static const earthRadiusKm = 6371.0;

  static double bearingToKaaba(double latitude, double longitude) {
    final lat1 = _radians(latitude);
    final lat2 = _radians(kaabaLatitude);
    final deltaLongitude = _radians(kaabaLongitude - longitude);
    final y = math.sin(deltaLongitude) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLongitude);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  static double distanceToKaabaKm(double latitude, double longitude) {
    final lat1 = _radians(latitude);
    final lat2 = _radians(kaabaLatitude);
    final dLat = lat2 - lat1;
    final dLon = _radians(kaabaLongitude - longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Great-circle points so the long Qibla route draws correctly on a map.
  static List<({double latitude, double longitude})> pathToKaaba(
    double latitude,
    double longitude, {
    int segments = 48,
  }) {
    final startLat = _radians(latitude);
    final startLon = _radians(longitude);
    final endLat = _radians(kaabaLatitude);
    final endLon = _radians(kaabaLongitude);
    final delta = 2 * math.asin(math.sqrt(
      math.pow(math.sin((endLat - startLat) / 2), 2) +
          math.cos(startLat) * math.cos(endLat) *
              math.pow(math.sin((endLon - startLon) / 2), 2),
    ));
    if (delta < 1e-10) {
      return [(latitude: latitude, longitude: longitude),
        (latitude: kaabaLatitude, longitude: kaabaLongitude)];
    }
    return List.generate(segments + 1, (index) {
      final fraction = index / segments;
      final a = math.sin((1 - fraction) * delta) / math.sin(delta);
      final b = math.sin(fraction * delta) / math.sin(delta);
      final x = a * math.cos(startLat) * math.cos(startLon) +
          b * math.cos(endLat) * math.cos(endLon);
      final y = a * math.cos(startLat) * math.sin(startLon) +
          b * math.cos(endLat) * math.sin(endLon);
      final z = a * math.sin(startLat) + b * math.sin(endLat);
      return (
        latitude: math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi,
        longitude: math.atan2(y, x) * 180 / math.pi,
      );
    });
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
