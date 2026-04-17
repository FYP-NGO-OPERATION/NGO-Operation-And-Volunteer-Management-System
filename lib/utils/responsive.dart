import 'package:flutter/material.dart';
import '../config/app_constants.dart';

/// Responsive layout helper — adapts to mobile, tablet, desktop.
class Responsive {
  Responsive._();

  /// Check device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint &&
      MediaQuery.of(context).size.width < AppConstants.desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;

  /// Get screen width
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get responsive horizontal padding
  static double horizontalPadding(BuildContext context) {
    final width = screenWidth(context);
    if (width < AppConstants.mobileBreakpoint) return 20;
    if (width < AppConstants.tabletBreakpoint) return 40;
    if (width < AppConstants.desktopBreakpoint) return 80;
    return (width - AppConstants.maxContentWidth * 2) / 2; // Center content
  }

  /// Get form width (constrained on large screens)
  static double formWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width < AppConstants.mobileBreakpoint) return width;
    if (width < AppConstants.tabletBreakpoint) return AppConstants.maxContentWidth;
    return AppConstants.maxContentWidth;
  }

  /// Get logo size based on screen
  static double logoSize(BuildContext context) {
    if (isMobile(context)) return 100;
    if (isTablet(context)) return 120;
    return 140;
  }

  /// Get grid columns for stats
  static int gridColumns(BuildContext context) {
    final width = screenWidth(context);
    if (width < AppConstants.mobileBreakpoint) return 2;
    if (width < AppConstants.tabletBreakpoint) return 3;
    return 4;
  }
}

/// Widget that wraps content in a centered, max-width constrained box.
/// Perfect for forms on web/tablet/desktop.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          child: child,
        ),
      ),
    );
  }
}
