import 'package:flutter/material.dart';

/// Design Tokens — Borders, Shadows, Radii, Opacity
class AppTokens {
  AppTokens._();

  // ─── BORDER RADIUS ───
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusPill = 999.0;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusPill = BorderRadius.circular(radiusPill);

  // ─── SHADOWS ───
  static final List<BoxShadow> shadowSoft = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static final List<BoxShadow> shadowMedium = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static final List<BoxShadow> shadowStrong = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static final List<BoxShadow> shadowFloating = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 16)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> shadowGlow(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4)),
  ];

  // ─── BORDERS ───
  static BorderSide borderLight = BorderSide(color: Colors.grey.withValues(alpha: 0.15));
  static BorderSide borderMedium = BorderSide(color: Colors.grey.withValues(alpha: 0.3));
  static const BorderSide borderFocus = BorderSide(color: Color(0xFF1A6B3C), width: 2);
  static const BorderSide borderDanger = BorderSide(color: Color(0xFFDC2626), width: 1.5);

  // ─── OPACITY ───
  static const double opacityDisabled = 0.38;
  static const double opacityHover = 0.08;
  static const double opacityPressed = 0.12;
  static const double opacityFocus = 0.12;
  static const double opacityOverlay = 0.5;
  static const double opacityGlass = 0.15;

  // ─── ICON SIZES ───
  static const double iconXs = 14.0;
  static const double iconSm = 18.0;
  static const double iconMd = 22.0;
  static const double iconLg = 28.0;
  static const double iconXl = 36.0;
  static const double iconHero = 48.0;

  // ─── AVATAR SIZES ───
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarHero = 120.0;

  // ─── BUTTON SIZES ───
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightXl = 56.0;
}
