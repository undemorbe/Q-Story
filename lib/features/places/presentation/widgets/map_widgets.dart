import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/theme_ext.dart';
import '../../domain/entities/place.dart';
import 'place_labels.dart';

/// Pin for a place: colour by source, glyph by category, gold when visited.
class PlacePin extends StatelessWidget {
  const PlacePin({super.key, required this.place, required this.visited, this.isTarget = false});

  final Place place;
  final bool visited;
  final bool isTarget;

  static const double width = 44;
  static const double height = 54;

  @override
  Widget build(BuildContext context) {
    final color = visited ? context.gold : place.source.color;
    final bg = visited ? context.goldContainer : context.surfaceClr;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: color, width: isTarget ? 3 : 1.6),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isTarget ? 0.8 : 0.4),
                  blurRadius: isTarget ? 18 : 10,
                  spreadRadius: isTarget ? 4 : 1,
                ),
              ],
            ),
            child: Icon(visited ? Icons.check : place.category.icon, color: color, size: 20),
          ),
          Positioned(
            bottom: 0,
            child: CustomPaint(size: const Size(12, 16), painter: _SpikePainter(color: color, bgColor: bg)),
          ),
        ],
      ),
    );
  }
}

class _SpikePainter extends CustomPainter {
  const _SpikePainter({required this.color, required this.bgColor});
  final Color color;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = bgColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_SpikePainter old) => old.color != color || old.bgColor != bgColor;
}

class ClusterBubble extends StatelessWidget {
  const ClusterBubble({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final gold = context.gold;
    return Container(
      decoration: BoxDecoration(
        color: context.goldContainer,
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 1.5),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.45), blurRadius: 14, spreadRadius: 2)],
      ),
      child: Center(
        child: Text('$count', style: GoogleFonts.cinzel(color: gold, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}

/// Current position: dot + heading wedge + pulsing accuracy halo.
class UserLocationDot extends StatefulWidget {
  const UserLocationDot({super.key, this.headingDeg, this.tracking = false});
  final double? headingDeg;
  final bool tracking;

  @override
  State<UserLocationDot> createState() => _UserLocationDotState();
}

class _UserLocationDotState extends State<UserLocationDot> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3D8BFF);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = widget.tracking ? _pulse.value : 0.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.tracking)
              Container(
                width: 20 + 40 * t,
                height: 20 + 40 * t,
                decoration: BoxDecoration(shape: BoxShape.circle, color: blue.withValues(alpha: 0.35 * (1 - t))),
              ),
            if (widget.headingDeg != null)
              Transform.rotate(
                angle: widget.headingDeg! * math.pi / 180,
                child: CustomPaint(size: const Size(44, 44), painter: _HeadingPainter(blue)),
              ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blue,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeadingPainter extends CustomPainter {
  const _HeadingPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final path = ui.Path()
      ..moveTo(c.dx, 0)
      ..lineTo(c.dx - 9, c.dy - 4)
      ..lineTo(c.dx + 9, c.dy - 4)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.55));
  }

  @override
  bool shouldRepaint(_HeadingPainter old) => old.color != color;
}

/// Square, gold-rimmed floating button used over the map.
class GothicFab extends StatelessWidget {
  const GothicFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.small = false,
    this.active = false,
    this.busy = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool small;
  final bool active;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final size = small ? 38.0 : 48.0;
    final gold = context.gold;
    final child = Material(
      color: active ? context.goldContainer : context.surfaceClr,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: active ? gold : context.outlineClr),
      ),
      elevation: 3,
      shadowColor: gold.withValues(alpha: 0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: busy
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: gold))
                : Icon(icon, color: gold, size: small ? 18 : 22),
          ),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}
