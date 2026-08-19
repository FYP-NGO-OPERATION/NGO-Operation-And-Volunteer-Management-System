import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_tokens.dart';
import '../theme/app_spacing.dart';

/// Upgraded App Theme — uses the premium design system
class AppTheme {
  AppTheme._();

  // ─── LIGHT THEME ───
  static ThemeData getLightTheme([Color? primaryColor, Color? secondaryColor]) {
    final primary = primaryColor ?? AppColors.primary;
    final secondary = secondaryColor ?? AppColors.secondary;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: AppColors.lightScaffoldBg,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.accent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.lightDivider,
      ),
      textTheme: AppTextStyles.textTheme(),

      // AppBar — clean white on light, dark header on dark
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightAppBarBg,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge(color: AppColors.lightTextPrimary),
        iconTheme: IconThemeData(color: primary),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightNavBarBg,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.neutral400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall(color: primary),
        unselectedLabelStyle: AppTextStyles.labelSmall(color: AppColors.neutral400),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusMd,
          side: BorderSide(color: AppColors.lightDivider.withValues(alpha: 0.5)),
        ),
        margin: AppSpacing.cardMargin,
        surfaceTintColor: Colors.transparent,
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTextStyles.button(),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputFill,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTextStyles.labelMedium(color: AppColors.lightTextSecondary),
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.lightTextHint),
        errorStyle: AppTextStyles.caption(color: AppColors.error),
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: AppColors.lightDivider, thickness: 1, space: 1),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: primary.withOpacity(0.1),
        labelStyle: AppTextStyles.labelMedium(color: primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLg),
        surfaceTintColor: Colors.transparent,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTextStyles.bodyMedium(color: Colors.white),
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: AppColors.neutral400,
        labelStyle: AppTextStyles.labelLarge(),
        unselectedLabelStyle: AppTextStyles.labelLarge(),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 2.5),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.neutral400),
        selectedLabelTextStyle: AppTextStyles.labelMedium(color: primary),
        unselectedLabelTextStyle: AppTextStyles.labelMedium(color: AppColors.neutral400),
        indicatorColor: primary.withOpacity(0.1),
      ),
    );
  }

  // ─── DARK THEME ───
  static ThemeData getDarkTheme([Color? primaryColor, Color? secondaryColor]) {
    final primaryLight = primaryColor ?? AppColors.primaryLight;
    final secondaryLight = secondaryColor ?? AppColors.secondaryLight;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: AppColors.darkScaffoldBg,
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        onPrimary: Colors.white,
        secondary: secondaryLight,
        onSecondary: Colors.white,
        tertiary: AppColors.accentLight,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.darkDivider,
      ),
      textTheme: AppTextStyles.textTheme(isDark: true),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkAppBarBg,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge(color: AppColors.darkTextPrimary),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkNavBarBg,
        selectedItemColor: primaryLight,
        unselectedItemColor: AppColors.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall(color: primaryLight),
        unselectedLabelStyle: AppTextStyles.labelSmall(color: AppColors.neutral500),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.borderRadiusMd,
          side: BorderSide(color: AppColors.darkDivider),
        ),
        margin: AppSpacing.cardMargin,
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: BorderSide(color: primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: AppTextStyles.button(),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputFill,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppTokens.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTextStyles.labelMedium(color: AppColors.darkTextSecondary),
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.darkTextHint),
        errorStyle: AppTextStyles.caption(color: AppColors.error),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.darkDivider, thickness: 1, space: 1),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        labelStyle: AppTextStyles.labelMedium(color: primaryLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
        side: const BorderSide(color: AppColors.darkDivider),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLg),
        surfaceTintColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
        backgroundColor: AppColors.neutral100,
        contentTextStyle: AppTextStyles.bodyMedium(color: AppColors.neutral900),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primaryLight,
        unselectedLabelColor: AppColors.neutral500,
        labelStyle: AppTextStyles.labelLarge(),
        unselectedLabelStyle: AppTextStyles.labelLarge(),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryLight, width: 2.5),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: IconThemeData(color: primaryLight),
        unselectedIconTheme: const IconThemeData(color: AppColors.neutral500),
        selectedLabelTextStyle: AppTextStyles.labelMedium(color: primaryLight),
        unselectedLabelTextStyle: AppTextStyles.labelMedium(color: AppColors.neutral500),
        indicatorColor: primaryLight.withOpacity(0.15),
      ),
    );
  }
}
