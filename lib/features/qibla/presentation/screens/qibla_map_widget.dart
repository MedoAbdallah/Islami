import 'package:flutter/material.dart';

/// Compatibility placeholder for projects that still reference the old map.
///
/// The Qibla map was removed. The live compass is shown by
/// QiblaCompassWidget in the Time tab.
@Deprecated('The Qibla map has been removed.')
class QiblaMapWidget extends StatelessWidget {
  const QiblaMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.locationLabel = 'موقعك',
    this.compact = false,
  });

  final double latitude;
  final double longitude;
  final String locationLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
