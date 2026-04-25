import 'package:flutter/material.dart';

/// Spacing System — 4pt/8pt Grid
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double mlg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double section = 40.0;
  static const double sectionLg = 48.0;
  static const double page = 64.0;
  static const double hero = 80.0;

  // Padding presets
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets pagePaddingWide = EdgeInsets.symmetric(horizontal: xl, vertical: lg);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: section);
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const double formFieldGap = lg;
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: lg, vertical: 14);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(xl, xl, xl, sectionLg);

  // Margins
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: sm);
  static const EdgeInsets sectionMargin = EdgeInsets.only(bottom: xl);

  // Vertical gaps (const SizedBox)
  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);
  static const SizedBox vGapSection = SizedBox(height: section);

  // Horizontal gaps
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);

  // Breakpoints
  static const double mobileMax = 600;
  static const double tabletMax = 900;
  static const double desktopMax = 1200;
  static const double maxContentWidth = 1200;
  static const double maxFormWidth = 480;
}
