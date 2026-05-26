import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme-aware color accessors. Use `context.gold` instead of
/// `AppColors.primaryGold` so colors switch correctly between
/// dark and light themes.
extension AppPalette on BuildContext {
  ColorScheme get _scheme => Theme.of(this).colorScheme;
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get gold => _scheme.primary;
  Color get goldContainer => _scheme.primaryContainer;
  Color get blood => _scheme.secondary;
  Color get bloodContainer => _scheme.secondaryContainer;
  Color get bgClr => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceClr => _scheme.surface;
  Color get surfaceVar =>
      _isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;
  Color get onBg => _scheme.onSurface;
  Color get outlineClr => _scheme.outline;
  Color get outlineVar => _scheme.outlineVariant;
  Color get errorClr => _scheme.error;
  Color get dim =>
      _isDark ? const Color(0xFF8A7A60) : AppColors.lightOutlineVariant;
}
