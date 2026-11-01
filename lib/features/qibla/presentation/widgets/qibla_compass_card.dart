import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_palette.dart';
import 'package:islami/features/qibla/domain/entities/qibla_math.dart';
import 'package:islami/core/theme/text_style_helper.dart';

class QiblaCompassCard extends StatelessWidget {
  const QiblaCompassCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    required this.heading,
    this.locationAvailable = true,
  });

  final double latitude;
  final double longitude;
  final String locationLabel;
  final double? heading;
  final bool locationAvailable;

  String _direction(double degrees) {
    const directions = [
      'شمال',
      'شمال شرق',
      'شرق',
      'جنوب شرق',
      'جنوب',
      'جنوب غرب',
      'غرب',
      'شمال غرب',
    ];
    return directions[((degrees + 22.5) ~/ 45) % directions.length];
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bearing = QiblaMath.bearingToKaaba(latitude, longitude);
    final hasHeading = heading != null && heading!.isFinite;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? p.background.withValues(alpha: .86) : p.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: p.primary.withValues(alpha: .34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .2 : .08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.explore_outlined, color: p.primary),
              const SizedBox(width: 9),
              Text(
                'اتجاه القبلة',
                style: TextStylesHelper.largeBodyTextStyle(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStylesHelper.smallLabelTextStyle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!locationAvailable)
            _CompassNotice(
              icon: Icons.location_off_rounded,
              message: 'حدّد موقعك أو اختر مدينتك لعرض اتجاه القبلة بدقة.',
            )
          else if (!hasHeading)
            _BearingWithoutSensor(
              bearing: bearing,
              direction: _direction(bearing),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final instrument = _CompassInstrument(
                  bearing: bearing,
                  heading: heading!,
                );
                final instructions = _CompassInstructions(
                  bearing: bearing,
                  direction: _direction(bearing),
                );

                if (constraints.maxWidth < 420) {
                  return Column(
                    children: [
                      instrument,
                      const SizedBox(height: 12),
                      instructions,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: instructions),
                    const SizedBox(width: 8),
                    instrument,
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CompassInstructions extends StatelessWidget {
  const _CompassInstructions({required this.bearing, required this.direction});

  final double bearing;
  final String direction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${bearing.round()}°',
          style: TextStylesHelper.largeTextStyle(context).copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'من الشمال · $direction',
          style: TextStylesHelper.mediumLabelTextStyle(
            context,
            textColor: p.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'حرّك الهاتف حتى يشير رمز الكعبة إلى القبلة.',
          style: TextStylesHelper.smallLabelTextStyle(
            context,
            textColor: p.onBackground.withValues(alpha: .68),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.screen_rotation_alt_rounded,
              color: p.primary.withValues(alpha: .9),
              size: 17,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'أبعد الهاتف عن المغناطيس والمعادن.',
                style: TextStylesHelper.smallBodyTextStyle(
                  context,
                  textColor: p.onBackground.withValues(alpha: .58),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BearingWithoutSensor extends StatelessWidget {
  const _BearingWithoutSensor({required this.bearing, required this.direction});

  final double bearing;
  final String direction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _CompassNotice(
      icon: Icons.explore_off_rounded,
      message:
          'زاوية القبلة ${bearing.round()}° باتجاه $direction من الشمال. '
          'بوصلة الهاتف غير متاحة، لذلك لا يمكن عرض اتجاه السهم.',
    );
  }
}

class _CompassNotice extends StatelessWidget {
  const _CompassNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: p.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStylesHelper.smallBodyTextStyle(
                context,
                textColor: p.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassInstrument extends StatefulWidget {
  const _CompassInstrument({required this.bearing, required this.heading});

  final double bearing;
  final double heading;

  @override
  State<_CompassInstrument> createState() => _CompassInstrumentState();
}

class _CompassInstrumentState extends State<_CompassInstrument> {
  double? _unwrappedTurns;

  @override
  void didUpdateWidget(covariant _CompassInstrument oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bearing != widget.bearing ||
        oldWidget.heading != widget.heading) {
      _updateTurns();
    }
  }

  void _updateTurns() {
    final target = _normalizedBearing / 360;
    final current = _unwrappedTurns ?? target;
    final delta = ((target - current + .5) % 1) - .5;
    _unwrappedTurns = current + delta;
  }

  double get _normalizedBearing =>
      (widget.bearing - widget.heading + 360) % 360;

  @override
  Widget build(BuildContext context) {
    _unwrappedTurns ??= _normalizedBearing / 360;
    const markerRadius = 76.0;
    const compassCenter = 95.0;
    const markerSize = 38.0;
    final qiblaAngle = (_normalizedBearing - 90) * math.pi / 180;
    final markerLeft =
        compassCenter + markerRadius * math.cos(qiblaAngle) - markerSize / 2;
    final markerTop =
        compassCenter + markerRadius * math.sin(qiblaAngle) - markerSize / 2;

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const _MetalCompassShell(),
          Transform.rotate(
            angle: -widget.heading * math.pi / 180,
            child: const _CompassDial(),
          ),
          AnimatedRotation(
            turns: _unwrappedTurns!,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: const _CompassNeedle(),
          ),
          const _CompassHub(),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            left: markerLeft,
            top: markerTop,
            child: const _KaabaBadge(),
          ),
        ],
      ),
    );
  }
}

class _MetalCompassShell extends StatelessWidget {
  const _MetalCompassShell();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 184,
      height: 184,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFB9BEC0),
            Color(0xFF686D70),
            Color(0xFFE9EBE9),
            Color(0xFF7A8081),
          ],
          stops: [0, .22, .52, .76, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .55),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Color(0x44FFFFFF),
            blurRadius: 5,
            offset: Offset(-3, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF45494B),
                const Color(0xFF17191A),
                Colors.black.withValues(alpha: .96),
              ],
              stops: const [0, .72, 1],
            ),
            border: Border.all(color: const Color(0xFF4B5051), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _CompassDial extends StatelessWidget {
  const _CompassDial();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(168),
      painter: _CompassDialPainter(),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 5;
    final silver = const Color(0xFFC8CDCC);
    final green = const Color(0xFF24D568);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = silver.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      center,
      radius - 13,
      Paint()
        ..color = silver.withValues(alpha: .35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (var degree = 0; degree < 360; degree += 5) {
      final angle = (degree - 90) * math.pi / 180;
      final isCardinal = degree % 90 == 0;
      final isMajor = degree % 30 == 0;
      final tickLength = isCardinal ? 13.0 : (isMajor ? 9.0 : 5.0);
      final start = radius - tickLength;
      final end = radius - 2;
      canvas.drawLine(
        Offset(
          center.dx + start * math.cos(angle),
          center.dy + start * math.sin(angle),
        ),
        Offset(
          center.dx + end * math.cos(angle),
          center.dy + end * math.sin(angle),
        ),
        Paint()
          ..color = silver.withValues(alpha: isMajor ? .9 : .56)
          ..strokeWidth = isCardinal ? 1.8 : 1,
      );
    }

    _drawLabel(canvas, 'N', Offset(center.dx, center.dy - radius + 25),
        green, 18, FontWeight.w800);
    _drawLabel(canvas, 'E', Offset(center.dx + radius - 24, center.dy),
        silver, 15, FontWeight.w700);
    _drawLabel(canvas, 'S', Offset(center.dx, center.dy + radius - 23),
        silver, 15, FontWeight.w700);
    _drawLabel(canvas, 'W', Offset(center.dx - radius + 24, center.dy),
        silver, 15, FontWeight.w700);

    const intercardinal = ['NE', 'SE', 'SW', 'NW'];
    for (var i = 0; i < intercardinal.length; i++) {
      final angle = (45 + i * 90 - 90) * math.pi / 180;
      _drawLabel(
        canvas,
        intercardinal[i],
        Offset(center.dx + (radius - 25) * math.cos(angle),
            center.dy + (radius - 25) * math.sin(angle)),
        silver.withValues(alpha: .7),
        7,
        FontWeight.w600,
      );
    }

    // Fine inner compass rose and a soft central guide.
    for (var degree = 0; degree < 360; degree += 45) {
      final angle = degree * math.pi / 180;
      final inner = radius * .29;
      final outer = radius * .43;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
            center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle),
            center.dy + outer * math.sin(angle)),
        Paint()
          ..color = silver.withValues(alpha: .48)
          ..strokeWidth = degree % 90 == 0 ? 1.4 : .8,
      );
    }
    canvas.drawCircle(
      center,
      radius * .22,
      Paint()
        ..color = const Color(0xFFBFC4C4).withValues(alpha: .13)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawLabel(Canvas canvas, String label, Offset center, Color color,
      double fontSize, FontWeight weight) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: .6,
          shadows: const [
            Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) => false;
}

class _CompassNeedle extends StatelessWidget {
  const _CompassNeedle();

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(64, 122),
    painter: _CompassNeedlePainter(),
  );
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final middle = size.height / 2;
    final north = Path()
      ..moveTo(x, 5)
      ..lineTo(x + 14, middle + 5)
      ..lineTo(x, middle - 8)
      ..lineTo(x - 14, middle + 5)
      ..close();
    canvas.drawPath(
      north,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF9AFFB7), Color(0xFF18C85C), Color(0xFF087A3B)],
        ).createShader(Rect.fromLTWH(x - 14, 5, 28, middle)),
    );

    final south = Path()
      ..moveTo(x, size.height - 5)
      ..lineTo(x + 10, middle - 1)
      ..lineTo(x, middle + 8)
      ..lineTo(x - 10, middle - 1)
      ..close();
    canvas.drawPath(
      south,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFE6E8E6), Color(0xFF73797A)],
        ).createShader(Rect.fromLTWH(x - 10, middle, 20, middle)),
    );
    canvas.drawLine(
      Offset(x, 12),
      Offset(x, size.height - 12),
      Paint()
        ..color = Colors.white.withValues(alpha: .7)
        ..strokeWidth = .7,
    );
  }

  @override
  bool shouldRepaint(covariant _CompassNeedlePainter oldDelegate) => false;
}

class _CompassHub extends StatelessWidget {
  const _CompassHub();

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFADB2B3), Color(0xFF4B5052)],
      ),
      border: Border.all(color: const Color(0xFFE2E5E3), width: 1.5),
      boxShadow: const [
        BoxShadow(color: Colors.black87, blurRadius: 5, offset: Offset(0, 2)),
      ],
    ),
    child: Center(
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFF2CE375),
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

class _KaabaBadge extends StatelessWidget {
  const _KaabaBadge();

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/kaaba.png',
    width: 30,
    height: 30,
    fit: BoxFit.contain,
  );
}
