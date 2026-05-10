import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
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

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.cinzelDecorative(color: AppColors.onBackground, fontSize: 57),
      displayMedium: GoogleFonts.cinzelDecorative(color: AppColors.onBackground, fontSize: 45),
      displaySmall: GoogleFonts.cinzelDecorative(color: AppColors.onBackground, fontSize: 36),
      headlineLarge: GoogleFonts.cinzelDecorative(color: AppColors.onBackground, fontSize: 32),
      headlineMedium: GoogleFonts.cinzelDecorative(color: AppColors.onBackground, fontSize: 26),
      headlineSmall: GoogleFonts.cinzelDecorative(color: AppColors.onBackground, fontSize: 22),
      titleLarge: GoogleFonts.cinzel(color: AppColors.onBackground, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.cinzel(color: AppColors.onBackground, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.cinzel(color: AppColors.onBackground, fontSize: 13, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.crimsonText(color: AppColors.onBackground, fontSize: 18),
      bodyMedium: GoogleFonts.crimsonText(color: AppColors.onSurface, fontSize: 16),
      bodySmall: GoogleFonts.crimsonText(color: AppColors.onSurface, fontSize: 14),
      labelLarge: GoogleFonts.cinzel(color: AppColors.onBackground, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8),
      labelMedium: GoogleFonts.cinzel(color: AppColors.onSurface, fontSize: 11, letterSpacing: 0.5),
      labelSmall: GoogleFonts.cinzel(color: AppColors.onSurface, fontSize: 10),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryGold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzelDecorative(
          color: AppColors.primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
        actionsIconTheme: const IconThemeData(color: AppColors.primaryGold),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.outline, width: 1),
          borderRadius: BorderRadius.zero,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryGold, size: 22);
          }
          return const IconThemeData(color: Color(0xFF8A7A60), size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cinzel(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.cinzel(color: const Color(0xFF8A7A60), fontSize: 10);
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.background,
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
          foregroundColor: AppColors.primaryGold,
          side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
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
          foregroundColor: AppColors.primaryGold,
          textStyle: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        labelStyle: GoogleFonts.cinzel(color: AppColors.onSurface, fontSize: 13),
        floatingLabelStyle: GoogleFonts.cinzel(color: AppColors.primaryGold, fontSize: 12),
        hintStyle: GoogleFonts.crimsonText(color: const Color(0xFF8A7A60), fontSize: 16),
        prefixIconColor: AppColors.outline,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: AppColors.outline, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: AppColors.outline, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: AppColors.outline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primaryGold,
        textColor: AppColors.onSurface,
        tileColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cinzel(
          color: AppColors.onBackground,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.crimsonText(
          color: AppColors.onSurface,
          fontSize: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryGold;
          return const Color(0xFF5C4A2A);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryContainer;
          return AppColors.surfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.outline;
          return AppColors.outlineVariant;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryGold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.background),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryGold;
          return AppColors.outline;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 12),
        ),
        labelColor: AppColors.primaryGold,
        unselectedLabelColor: Color(0xFF8A7A60),
        labelStyle: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 12, letterSpacing: 0.5),
        dividerColor: AppColors.outline,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGold,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: GoogleFonts.crimsonText(color: AppColors.onBackground, fontSize: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: AppColors.outline),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: AppColors.outline),
        ),
        titleTextStyle: GoogleFonts.cinzelDecorative(color: AppColors.onBackground, fontSize: 18),
        contentTextStyle: GoogleFonts.crimsonText(color: AppColors.onSurface, fontSize: 16),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
          side: BorderSide(color: AppColors.outline),
        ),
        dragHandleColor: AppColors.outline,
      ),
      iconTheme: const IconThemeData(color: AppColors.primaryGold),
    );
  }

  static ThemeData get lightTheme => darkTheme;
}
