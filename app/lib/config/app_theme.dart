import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_tokens.dart';
import '../theme/app_spacing.dart';

/// Upgraded App Theme — uses the premium design system
class AppTheme {
  AppTheme._();

  // ─── LIGHT THEME ───
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightScaffoldBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
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
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge(color: AppColors.lightTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightNavBarBg,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall(color: AppColors.primary),
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppTokens.buttonHeightMd),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, AppTokens.buttonHeightMd),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
        backgroundColor: AppColors.primarySurface,
        labelStyle: AppTextStyles.labelMedium(color: AppColors.primary),
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
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.neutral400,
        labelStyle: AppTextStyles.labelLarge(),
        unselectedLabelStyle: AppTextStyles.labelLarge(),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.neutral400),
        selectedLabelTextStyle: AppTextStyles.labelMedium(color: AppColors.primary),
        unselectedLabelTextStyle: AppTextStyles.labelMedium(color: AppColors.neutral400),
        indicatorColor: AppColors.primarySurface,
      ),
    );
  }

  // ─── DARK THEME ───
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.darkScaffoldBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryLight,
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
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.neutral500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall(color: AppColors.primaryLight),
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
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppTokens.buttonHeightMd),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          minimumSize: const Size(double.infinity, AppTokens.buttonHeightMd),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
          textStyle: AppTextStyles.button(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
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
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
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
        labelStyle: AppTextStyles.labelMedium(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusPill)),
        side: BorderSide(color: AppColors.darkDivider),
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
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.neutral500,
        labelStyle: AppTextStyles.labelLarge(),
        unselectedLabelStyle: AppTextStyles.labelLarge(),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2.5),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemPadding,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: const IconThemeData(color: AppColors.primaryLight),
        unselectedIconTheme: const IconThemeData(color: AppColors.neutral500),
        selectedLabelTextStyle: AppTextStyles.labelMedium(color: AppColors.primaryLight),
        unselectedLabelTextStyle: AppTextStyles.labelMedium(color: AppColors.neutral500),
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
      ),
    );
  }
}
