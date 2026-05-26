import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => _build(_DarkScheme());
  static ThemeData get lightTheme => _build(_LightScheme());

  static ThemeData _build(_ThemeScheme s) {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.cinzelDecorative(color: s.onBg, fontSize: 57),
      displayMedium: GoogleFonts.cinzelDecorative(color: s.onBg, fontSize: 45),
      displaySmall: GoogleFonts.cinzelDecorative(color: s.onBg, fontSize: 36),
      headlineLarge: GoogleFonts.cinzelDecorative(color: s.onBg, fontSize: 32),
      headlineMedium: GoogleFonts.cinzelDecorative(color: s.onBg, fontSize: 26),
      headlineSmall: GoogleFonts.cinzelDecorative(color: s.onBg, fontSize: 22),
      titleLarge: GoogleFonts.cinzel(color: s.onBg, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.cinzel(color: s.onBg, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.cinzel(color: s.onBg, fontSize: 13, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.crimsonText(color: s.onBg, fontSize: 18),
      bodyMedium: GoogleFonts.crimsonText(color: s.onSurface, fontSize: 16),
      bodySmall: GoogleFonts.crimsonText(color: s.onSurface, fontSize: 14),
      labelLarge: GoogleFonts.cinzel(color: s.onBg, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8),
      labelMedium: GoogleFonts.cinzel(color: s.onSurface, fontSize: 11, letterSpacing: 0.5),
      labelSmall: GoogleFonts.cinzel(color: s.onSurface, fontSize: 10),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: s.colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: s.bg,
      appBarTheme: AppBarTheme(
        backgroundColor: s.bg,
        foregroundColor: s.gold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzelDecorative(
          color: s.gold,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: s.gold),
        actionsIconTheme: IconThemeData(color: s.gold),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: s.outline, width: 1),
          borderRadius: BorderRadius.zero,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: s.surface,
        indicatorColor: s.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: s.gold, size: 22);
          }
          return IconThemeData(color: s.dim, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cinzel(color: s.gold, fontSize: 10, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.cinzel(color: s.dim, fontSize: 10);
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.gold,
          foregroundColor: s.bg,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: s.gold,
          side: BorderSide(color: s.gold, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          textStyle: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: s.gold,
          textStyle: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.surfaceVariant,
        labelStyle: GoogleFonts.cinzel(color: s.onSurface, fontSize: 13),
        floatingLabelStyle: GoogleFonts.cinzel(color: s.gold, fontSize: 12),
        hintStyle: GoogleFonts.crimsonText(color: s.dim, fontSize: 16),
        prefixIconColor: s.outline,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: s.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: s.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: s.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: s.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: s.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: s.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: s.outline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: s.outline,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: s.gold,
        textColor: s.onSurface,
        tileColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cinzel(
          color: s.onBg,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.crimsonText(
          color: s.onSurface,
          fontSize: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return s.gold;
          return s.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return s.primaryContainer;
          return s.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return s.outline;
          return s.outlineVariant;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return s.gold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(s.bg),
        side: BorderSide(color: s.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return s.gold;
          return s.outline;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: s.gold, width: 2),
          insets: const EdgeInsets.symmetric(horizontal: 12),
        ),
        labelColor: s.gold,
        unselectedLabelColor: s.dim,
        labelStyle: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 12, letterSpacing: 0.5),
        dividerColor: s.outline,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: s.gold),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: s.surfaceVariant,
        contentTextStyle: GoogleFonts.crimsonText(color: s.onBg, fontSize: 15),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: s.outline),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: s.outline),
        ),
        titleTextStyle: GoogleFonts.cinzelDecorative(color: s.onBg, fontSize: 18),
        contentTextStyle: GoogleFonts.crimsonText(color: s.onSurface, fontSize: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          side: BorderSide(color: s.outline),
        ),
        dragHandleColor: s.outline,
      ),
      iconTheme: IconThemeData(color: s.gold),
    );
  }
}

// ─── Scheme abstraction ───────────────────────────────────────────────────────

abstract class _ThemeScheme {
  ColorScheme get colorScheme;
  Color get bg;
  Color get surface;
  Color get surfaceVariant;
  Color get gold;
  Color get primaryContainer;
  Color get onBg;
  Color get onSurface;
  Color get outline;
  Color get outlineVariant;
  Color get error;
  Color get dim;
}

// ─── Dark ─────────────────────────────────────────────────────────────────────

class _DarkScheme implements _ThemeScheme {
  @override Color get bg => AppColors.background;
  @override Color get surface => AppColors.surface;
  @override Color get surfaceVariant => AppColors.surfaceVariant;
  @override Color get gold => AppColors.primaryGold;
  @override Color get primaryContainer => AppColors.primaryContainer;
  @override Color get onBg => AppColors.onBackground;
  @override Color get onSurface => AppColors.onSurface;
  @override Color get outline => AppColors.outline;
  @override Color get outlineVariant => AppColors.outlineVariant;
  @override Color get error => AppColors.error;
  @override Color get dim => const Color(0xFF8A7A60);

  @override
  ColorScheme get colorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryGold,
    onPrimary: AppColors.background,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryGold,
    secondary: AppColors.secondaryRed,
    onSecondary: AppColors.onBackground,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onBackground,
    tertiary: AppColors.primaryGold,
    onTertiary: AppColors.background,
    tertiaryContainer: AppColors.primaryContainer,
    onTertiaryContainer: AppColors.primaryGold,
    error: AppColors.error,
    onError: AppColors.onBackground,
    errorContainer: Color(0xFF5C0A0A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurface,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.onBackground,
    onInverseSurface: AppColors.background,
    inversePrimary: AppColors.primaryGoldDark,
    surfaceTint: Colors.transparent,
  );
}

// ─── Light (aged parchment) ───────────────────────────────────────────────────

class _LightScheme implements _ThemeScheme {
  @override Color get bg => AppColors.lightBackground;
  @override Color get surface => AppColors.lightSurface;
  @override Color get surfaceVariant => AppColors.lightSurfaceVariant;
  @override Color get gold => AppColors.lightGold;
  @override Color get primaryContainer => AppColors.lightGoldContainer;
  @override Color get onBg => AppColors.lightOnBackground;
  @override Color get onSurface => AppColors.lightOnSurface;
  @override Color get outline => AppColors.lightOutline;
  @override Color get outlineVariant => AppColors.lightOutlineVariant;
  @override Color get error => AppColors.lightError;
  @override Color get dim => AppColors.lightOutlineVariant;

  @override
  ColorScheme get colorScheme => ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightGold,
    onPrimary: AppColors.lightBackground,
    primaryContainer: AppColors.lightGoldContainer,
    onPrimaryContainer: AppColors.lightOnBackground,
    secondary: AppColors.lightSecondaryRed,
    onSecondary: AppColors.lightBackground,
    secondaryContainer: AppColors.lightSecondaryContainer,
    onSecondaryContainer: AppColors.lightOnBackground,
    tertiary: AppColors.lightGold,
    onTertiary: AppColors.lightBackground,
    tertiaryContainer: AppColors.lightGoldContainer,
    onTertiaryContainer: AppColors.lightOnBackground,
    error: AppColors.lightError,
    onError: AppColors.lightBackground,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    onSurfaceVariant: AppColors.lightOnSurface,
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: AppColors.lightOnBackground,
    onInverseSurface: AppColors.lightBackground,
    inversePrimary: AppColors.lightGoldMid,
    surfaceTint: Colors.transparent,
  );
}
