import 'package:flutter/material.dart';
import 'theme_ext.dart';

class GothicBackground extends StatelessWidget {
  final Widget child;
  const GothicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isDark)
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.transparent, Color(0x80000000)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class GothicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const GothicCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final gold = context.gold;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.surfaceClr,
        border: Border.all(color: context.outlineClr, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: Center(
              child: child,
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: Text(
              '✦',
              style: TextStyle(color: gold, fontSize: 7, height: 1),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Text(
              '✦',
              style: TextStyle(color: gold, fontSize: 7, height: 1),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Text(
              '✦',
              style: TextStyle(color: gold, fontSize: 7, height: 1),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Text(
              '✦',
              style: TextStyle(color: gold, fontSize: 7, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class GothicDivider extends StatelessWidget {
  const GothicDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: context.outlineClr)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '◆',
              style: TextStyle(color: context.gold, fontSize: 10),
            ),
          ),
          Expanded(child: Container(height: 1, color: context.outlineClr)),
        ],
      ),
    );
  }
}

class GothicOrnamentHeader extends StatelessWidget {
  final String text;
  final double fontSize;

  const GothicOrnamentHeader({
    super.key,
    required this.text,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final gold = context.gold;
    return Column(
      children: [
        Text(
          '— ✦ ◆ ✦ —',
          style: TextStyle(
            color: gold.withValues(alpha: 0.6),
            fontSize: 16,
            letterSpacing: 4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'CinzelDecorative',
            color: gold,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
