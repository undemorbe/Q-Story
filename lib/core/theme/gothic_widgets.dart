import 'package:flutter/material.dart';
import 'app_colors.dart';

class GothicBackground extends StatelessWidget {
  final Widget child;
  const GothicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
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
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        border: Border.all(color: AppColors.outline, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
          const Positioned(
            top: 4,
            left: 4,
            child: Text(
              '✦',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 7, height: 1),
            ),
          ),
          const Positioned(
            top: 4,
            right: 4,
            child: Text(
              '✦',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 7, height: 1),
            ),
          ),
          const Positioned(
            bottom: 4,
            left: 4,
            child: Text(
              '✦',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 7, height: 1),
            ),
          ),
          const Positioned(
            bottom: 4,
            right: 4,
            child: Text(
              '✦',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 7, height: 1),
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
          Expanded(child: Container(height: 1, color: AppColors.outline)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '◆',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 10),
            ),
          ),
          Expanded(child: Container(height: 1, color: AppColors.outline)),
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
    return Column(
      children: [
        Text(
          '— ✦ ◆ ✦ —',
          style: TextStyle(
            color: AppColors.primaryGold.withValues(alpha: 0.6),
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
            color: AppColors.primaryGold,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
