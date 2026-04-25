import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_volunteer_app/config/app_constants.dart';
import 'package:ngo_volunteer_app/config/app_colors.dart';
import 'package:ngo_volunteer_app/theme/app_spacing.dart';

/// Unit tests for app configuration, constants, design tokens, and color system.
void main() {
  group('AppConstants', () {
    test('app info is defined', () {
      expect(AppConstants.appName, isNotEmpty);
      expect(AppConstants.orgName, isNotEmpty);
      expect(AppConstants.appTagline, isNotEmpty);
      expect(AppConstants.appVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
    });

    test('responsive breakpoints are in ascending order', () {
      expect(AppConstants.mobileBreakpoint, lessThan(AppConstants.tabletBreakpoint));
      expect(AppConstants.tabletBreakpoint, lessThan(AppConstants.desktopBreakpoint));
    });

    test('breakpoints are reasonable values', () {
      expect(AppConstants.mobileBreakpoint, greaterThanOrEqualTo(300));
      expect(AppConstants.desktopBreakpoint, lessThanOrEqualTo(1400));
    });

    test('image constraints are reasonable', () {
      expect(AppConstants.maxImageSizeBytes, greaterThan(0));
      expect(AppConstants.compressedImageQuality, inInclusiveRange(1, 100));
    });

    test('validation constants are reasonable', () {
      expect(AppConstants.minPasswordLength, greaterThanOrEqualTo(6));
      expect(AppConstants.maxNameLength, greaterThan(AppConstants.minPasswordLength));
      expect(AppConstants.phoneLength, equals(11)); // Pakistani format
    });

    test('Firebase collection names are defined', () {
      expect(AppConstants.usersCollection, isNotEmpty);
      expect(AppConstants.campaignsCollection, isNotEmpty);
      expect(AppConstants.donationsCollection, isNotEmpty);
      expect(AppConstants.volunteersCollection, isNotEmpty);
    });

    test('page size is positive', () {
      expect(AppConstants.pageSize, greaterThan(0));
    });
  });

  group('AppColors', () {
    test('primary colors are defined', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.primaryDark, isNotNull);
      expect(AppColors.primaryLight, isNotNull);
    });

    test('semantic colors are defined', () {
      expect(AppColors.success, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.info, isNotNull);
    });

    test('light theme colors are defined', () {
      expect(AppColors.lightScaffoldBg, isNotNull);
      expect(AppColors.lightCardBg, isNotNull);
      expect(AppColors.lightTextPrimary, isNotNull);
      expect(AppColors.lightTextSecondary, isNotNull);
    });

    test('dark theme colors are defined', () {
      expect(AppColors.darkScaffoldBg, isNotNull);
      expect(AppColors.darkCardBg, isNotNull);
      expect(AppColors.darkTextPrimary, isNotNull);
      expect(AppColors.darkTextSecondary, isNotNull);
    });

    test('primary and error colors are different', () {
      expect(AppColors.primary, isNot(equals(AppColors.error)));
    });
  });

  group('AppSpacing', () {
    test('spacing values are in ascending order', () {
      expect(AppSpacing.xxs, lessThan(AppSpacing.xs));
      expect(AppSpacing.xs, lessThan(AppSpacing.sm));
      expect(AppSpacing.sm, lessThan(AppSpacing.md));
      expect(AppSpacing.md, lessThan(AppSpacing.lg));
      expect(AppSpacing.lg, lessThan(AppSpacing.xl));
      expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
    });

    test('all spacing values are positive', () {
      expect(AppSpacing.xxs, greaterThan(0));
      expect(AppSpacing.xs, greaterThan(0));
      expect(AppSpacing.sm, greaterThan(0));
      expect(AppSpacing.md, greaterThan(0));
      expect(AppSpacing.lg, greaterThan(0));
    });
  });
}
