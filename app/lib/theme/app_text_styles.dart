import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ═══════════════════════════════════════════════════════════════
/// Premium Typography System — Hamesha Rahein Apke Saath
/// ═══════════════════════════════════════════════════════════════
/// Font stack: Inter (UI) + Poppins (headings)
/// Scale: Minor Third (1.2) modular scale
/// Accessibility: WCAG AA minimum 16px body text
/// ═══════════════════════════════════════════════════════════════
class AppTextStyles {
  AppTextStyles._();

  // ─── FONT FAMILIES ───
  static String get _headingFamily => GoogleFonts.poppins().fontFamily!;
  static String get _bodyFamily => GoogleFonts.inter().fontFamily!;

  // ─── DISPLAY ───
  /// Hero sections, splash screens (36px+)
  static TextStyle displayLarge({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    height: 1.1,
    color: color,
  );

  static TextStyle displayMedium({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.15,
    color: color,
  );

  static TextStyle displaySmall({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
    color: color,
  );

  // ─── HEADLINE ───
  /// Section titles, page headers
  static TextStyle headlineLarge({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
    color: color,
  );

  static TextStyle headlineMedium({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
    color: color,
  );

  static TextStyle headlineSmall({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: color,
  );

  // ─── TITLE ───
  /// Card titles, list headers, nav items
  static TextStyle titleLarge({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
    color: color,
  );

  static TextStyle titleMedium({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: color,
  );

  static TextStyle titleSmall({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: color,
  );

  // ─── BODY ───
  /// Main content text
  static TextStyle bodyLarge({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: color,
  );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: color,
  );

  static TextStyle bodySmall({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: color,
  );

  // ─── LABEL ───
  /// Chips, badges, tags, form labels
  static TextStyle labelLarge({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
    color: color,
  );

  static TextStyle labelMedium({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.4,
    color: color,
  );

  static TextStyle labelSmall({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
    color: color,
  );

  // ─── SPECIAL PURPOSE ───
  /// Button text
  static TextStyle button({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
    color: color,
  );

  /// Caption / helper text
  static TextStyle caption({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.4,
    color: color,
  );

  /// Overline / eyebrow text
  static TextStyle overline({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.4,
    color: color,
  );

  /// Stats / dashboard numbers
  static TextStyle statValue({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
    color: color,
  );

  /// Currency / donation amounts
  static TextStyle amount({Color? color}) => TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: color,
  );

  /// Navigation link text
  static TextStyle navLink({Color? color}) => TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: color,
  );

  // ─── FLUTTER TEXTTHEME INTEGRATION ───
  /// Use this in ThemeData to apply the system globally
  static TextTheme textTheme({bool isDark = false}) {
    return TextTheme(
      displayLarge: displayLarge(),
      displayMedium: displayMedium(),
      displaySmall: displaySmall(),
      headlineLarge: headlineLarge(),
      headlineMedium: headlineMedium(),
      headlineSmall: headlineSmall(),
      titleLarge: titleLarge(),
      titleMedium: titleMedium(),
      titleSmall: titleSmall(),
      bodyLarge: bodyLarge(),
      bodyMedium: bodyMedium(),
      bodySmall: bodySmall(),
      labelLarge: labelLarge(),
      labelMedium: labelMedium(),
      labelSmall: labelSmall(),
    );
  }
}
