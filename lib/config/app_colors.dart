import 'package:flutter/material.dart';

/// App-wide color constants for the NGO Volunteer Management System.
/// Green & white theme representing hope, growth, and service.
class AppColors {
  AppColors._(); // Prevent instantiation

  // ─── Primary (Green shades - NGO theme) ───
  static const Color primary = Color(0xFF2E7D32);        // Dark green
  static const Color primaryLight = Color(0xFF4CAF50);    // Medium green
  static const Color primaryDark = Color(0xFF1B5E20);     // Very dark green
  static const Color primarySurface = Color(0xFFE8F5E9);  // Very light green

  // ─── Background & Surface ───
  static const Color background = Color(0xFFF5F5F5);      // Light grey
  static const Color surface = Color(0xFFFFFFFF);          // White
  static const Color cardBg = Color(0xFFE8F5E9);           // Mint green card
  static const Color scaffoldBg = Color(0xFFFAFAFA);       // Off white

  // ─── Text ───
  static const Color textPrimary = Color(0xFF212121);      // Almost black
  static const Color textSecondary = Color(0xFF757575);    // Grey
  static const Color textHint = Color(0xFFBDBDBD);         // Light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);    // White on green

  // ─── Status Colors ───
  static const Color success = Color(0xFF4CAF50);          // Green
  static const Color error = Color(0xFFE53935);            // Red
  static const Color warning = Color(0xFFFFA726);          // Orange
  static const Color info = Color(0xFF29B6F6);             // Blue

  // ─── Campaign Type Colors ───
  static const Color winterDrive = Color(0xFF42A5F5);      // Blue
  static const Color ramadan = Color(0xFF66BB6A);           // Green
  static const Color eid = Color(0xFFFFCA28);               // Gold
  static const Color orphanage = Color(0xFFEF5350);         // Red
  static const Color custom = Color(0xFF78909C);            // Blue Grey

  // ─── Campaign Status Colors ───
  static const Color statusUpcoming = Color(0xFF42A5F5);   // Blue
  static const Color statusActive = Color(0xFF4CAF50);     // Green
  static const Color statusCompleted = Color(0xFF9E9E9E);  // Grey

  // ─── Misc ───
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shadow = Color(0x1A000000);           // 10% black
}
