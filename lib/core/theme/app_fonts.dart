import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The app's typefaces, all bundled in `assets/google_fonts` (no network).
///
/// Cormorant covers Latin and Cyrillic, so Russian text renders in the
/// intended serif instead of falling back to the system font.
abstract final class AppFonts {
  /// Headings, labels and buttons: classical small caps.
  static TextStyle display({
    Color? color,
    double? fontSize,
    FontWeight fontWeight = FontWeight.w600,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.cormorantSc(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// Running text. Medium weight keeps Cormorant readable at body sizes.
  static TextStyle body({
    Color? color,
    double? fontSize,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.cormorantGaramond(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// The "QStory" wordmark only (Latin).
  static TextStyle logo({Color? color, double? fontSize, FontWeight fontWeight = FontWeight.w700}) =>
      GoogleFonts.cinzelDecorative(color: color, fontSize: fontSize, fontWeight: fontWeight);
}
