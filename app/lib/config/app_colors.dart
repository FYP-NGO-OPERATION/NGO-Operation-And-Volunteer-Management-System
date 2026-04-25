import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// Premium Color System — Hamesha Rahein Apke Saath
/// ═══════════════════════════════════════════════════════════════
/// Inspired by: Stripe, Linear, Headspace
/// Color philosophy: Trust (green) + Warmth (amber) + Clarity (neutral)
///
/// Usage: AppColors.primary, AppColors.neutral[800], etc.
/// For theme-aware colors: Theme.of(context).colorScheme
/// ═══════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  // ─── PRIMARY BRAND ───
  // Deep forest green — conveys trust, growth, hope
  static const Color primary       = Color(0xFF1A6B3C);  // Main brand
  static const Color primaryLight  = Color(0xFF2E9B5A);  // Hover / accents
  static const Color primaryDark   = Color(0xFF0E4D29);  // Headers / emphasis
  static const Color primarySurface= Color(0xFFF0FAF4);  // Tinted backgrounds

  // ─── SECONDARY ───
  // Warm teal — trust, calmness, professionalism
  static const Color secondary      = Color(0xFF0D7377);
  static const Color secondaryLight = Color(0xFF14A3A8);
  static const Color secondaryDark  = Color(0xFF094F52);
  static const Color secondarySurface = Color(0xFFE8F8F8);

  // ─── ACCENT ───
  // Premium amber — warmth, urgency, generosity (for donations)
  static const Color accent        = Color(0xFFE8A838);
  static const Color accentLight   = Color(0xFFF5C463);
  static const Color accentDark    = Color(0xFFBF8420);
  static const Color accentSurface = Color(0xFFFFF8E8);

  // ─── STATUS COLORS ───
  static const Color success       = Color(0xFF16A34A);
  static const Color successLight  = Color(0xFFDCFCE7);
  static const Color error         = Color(0xFFDC2626);
  static const Color errorLight    = Color(0xFFFEE2E2);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color warningLight  = Color(0xFFFEF3C7);
  static const Color info          = Color(0xFF0EA5E9);
  static const Color infoLight     = Color(0xFFE0F2FE);

  // ─── NEUTRAL GRAYSCALE (50–900) ───
  static const Color neutral50  = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ─── NGO SEMANTIC COLORS ───
  /// Donation urgency spectrum
  static const Color donationUrgent    = Color(0xFFDC2626);
  static const Color donationHigh      = Color(0xFFF59E0B);
  static const Color donationNormal    = Color(0xFF16A34A);
  static const Color donationCompleted = Color(0xFF6B7280);

  /// Volunteer positivity spectrum
  static const Color volunteerActive    = Color(0xFF16A34A);
  static const Color volunteerPending   = Color(0xFFF59E0B);
  static const Color volunteerConfirmed = Color(0xFF0EA5E9);
  static const Color volunteerAbsent    = Color(0xFFEF4444);

  /// Campaign type chips
  static const Color winterDrive = Color(0xFF3B82F6);
  static const Color ramadan    = Color(0xFF22C55E);
  static const Color eid        = Color(0xFFEAB308);
  static const Color orphanage  = Color(0xFFEF4444);
  static const Color medical    = Color(0xFF8B5CF6);
  static const Color education  = Color(0xFF06B6D4);
  static const Color custom     = Color(0xFF64748B);

  // ═══════════════════════════════════════════════════
  // ─── LIGHT THEME PALETTE ───
  // ═══════════════════════════════════════════════════
  static const Color lightScaffoldBg     = Color(0xFFF8FAF9);
  static const Color lightCardBg         = Color(0xFFFFFFFF);
  static const Color lightSurface        = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F5F4);
  static const Color lightDivider        = Color(0xFFE8ECE9);
  static const Color lightTextPrimary    = Color(0xFF111827);
  static const Color lightTextSecondary  = Color(0xFF6B7280);
  static const Color lightTextHint       = Color(0xFF9CA3AF);
  static const Color lightTextDisabled   = Color(0xFFD1D5DB);
  static const Color lightInputFill      = Color(0xFFF3F5F4);
  static const Color lightAppBarBg       = Color(0xFFFFFFFF);
  static const Color lightNavBarBg       = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════
  // ─── DARK THEME PALETTE ───
  // ═══════════════════════════════════════════════════
  static const Color darkScaffoldBg      = Color(0xFF0F1110);
  static const Color darkCardBg          = Color(0xFF1A1D1B);
  static const Color darkSurface         = Color(0xFF1A1D1B);
  static const Color darkSurfaceVariant  = Color(0xFF252926);
  static const Color darkDivider         = Color(0xFF2D312E);
  static const Color darkTextPrimary     = Color(0xFFF3F4F6);
  static const Color darkTextSecondary   = Color(0xFF9CA3AF);
  static const Color darkTextHint        = Color(0xFF6B7280);
  static const Color darkTextDisabled    = Color(0xFF4B5563);
  static const Color darkInputFill       = Color(0xFF252926);
  static const Color darkAppBarBg        = Color(0xFF151815);
  static const Color darkNavBarBg        = Color(0xFF151815);

  // ─── GRADIENT PRESETS ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDark, primary, Color(0xFF2E9B5A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Color(0xCC000000), Color(0x00000000)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [neutral200, neutral100, neutral200],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient darkShimmerGradient = LinearGradient(
    colors: [darkCardBg, darkSurfaceVariant, darkCardBg],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // ─── GLASSMORPHISM ───
  static Color glassWhite  = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static Color glassDarkBg = Colors.black.withValues(alpha: 0.3);

  // ─── Backward compatibility aliases ───
  static const Color scaffoldBg    = lightScaffoldBg;
  static const Color textPrimary   = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textHint      = lightTextHint;
}
