import 'package:flutter/material.dart';

/// Complete color palette for light and dark themes.
class AppColors {
  AppColors._();

  // ─── Primary Brand Colors (same for both themes) ───
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primarySurface = Color(0xFFE8F5E9);

  // ─── Accent ───
  static const Color accent = Color(0xFF00796B);

  // ─── Status Colors (same for both themes) ───
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // ─── Campaign Type Colors (same for both themes) ───
  static const Color winterDrive = Color(0xFF42A5F5);
  static const Color ramadan = Color(0xFF66BB6A);
  static const Color eid = Color(0xFFFFCA28);
  static const Color orphanage = Color(0xFFEF5350);
  static const Color medical = Color(0xFF7E57C2);
  static const Color education = Color(0xFF26C6DA);
  static const Color custom = Color(0xFF78909C);

  // ═══════════════════════════════════════════════════
  // ─── LIGHT THEME COLORS ───
  // ═══════════════════════════════════════════════════
  static const Color lightScaffoldBg = Color(0xFFF0F4F0);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightTextHint = Color(0xFFBDBDBD);
  static const Color lightInputFill = Color(0xFFF5F5F5);
  static const Color lightAppBarBg = Color(0xFF2E7D32);

  // ═══════════════════════════════════════════════════
  // ─── DARK THEME COLORS ───
  // ═══════════════════════════════════════════════════
  static const Color darkScaffoldBg = Color(0xFF121212);
  static const Color darkCardBg = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFEAEAEA);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkTextHint = Color(0xFF616161);
  static const Color darkInputFill = Color(0xFF2A2A2A);
  static const Color darkAppBarBg = Color(0xFF1A1A1A);

  // ─── Dynamic getters (backward compatibility) ───
  // These are kept for existing code to compile.
  // Actual theme colors come from Theme.of(context) now.
  static const Color scaffoldBg = lightScaffoldBg;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textHint = lightTextHint;
}
