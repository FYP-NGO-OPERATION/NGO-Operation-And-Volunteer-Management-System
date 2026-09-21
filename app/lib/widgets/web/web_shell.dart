import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert' as dart_convert;
import '../../providers/ngo_provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';

/// Premium web sidebar shell — wraps post-login screens on desktop/tablet.
/// On mobile, returns child directly (bottom nav handles navigation).
class WebShell extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<Map<String, dynamic>> tabs;
  final bool isAdmin;
  final String userName;
  final String? userImageUrl;
  final VoidCallback onLogout;

  const WebShell({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.tabs,
    required this.isAdmin,
    required this.userName,
    this.userImageUrl,
    required this.onLogout,
  });

  @override
  State<WebShell> createState() => _WebShellState();
}

class _WebShellState extends State<WebShell> {
  bool _sidebarExpanded = true;

  List<_SidebarItem> get _items {
    return widget.tabs.asMap().entries.map((e) {
      return _SidebarItem(
        icon: e.value['icon'] as IconData,
        label: e.value['label'] as String,
        index: e.key,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= AppConstants.desktopBreakpoint;
    final isTablet =
        screenWidth >= AppConstants.mobileBreakpoint &&
        screenWidth < AppConstants.desktopBreakpoint;

    // On mobile, just return the tab content — bottom nav handles navigation
    if (!isWide && !isTablet) {
      return widget.tabs[widget.currentIndex < widget.tabs.length
              ? widget.currentIndex
              : 0]['screen']
          as Widget;
    }

    // Tablet: narrow rail. Desktop: full sidebar.
    final sidebarWidth = isWide && _sidebarExpanded ? 240.0 : 72.0;

    return Scaffold(
      body: Row(
        children: [
          // ─── Sidebar ───
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo header
                _buildLogoHeader(isDark, isWide && _sidebarExpanded),
                Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                ),

                // Navigation items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    children: _items
                        .map(
                          (item) => _buildNavItem(
                            item,
                            isDark,
                            isWide && _sidebarExpanded,
                          ),
                        )
                        .toList(),
                  ),
                ),

                // Bottom section
                Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                ),
                _buildUserFooter(isDark, isWide && _sidebarExpanded),
              ],
            ),
          ),

          // ─── Main Content Area ───
          Expanded(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(isDark, isWide),
                Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                ),
                // Content
                Expanded(
                  child:
                      widget.tabs[widget.currentIndex < widget.tabs.length
                              ? widget.currentIndex
                              : 0]['screen']
                          as Widget,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader(bool isDark, bool expanded) {
    final currentNgo = Provider.of<NgoProvider>(context).currentNgo;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? AppSpacing.lg : AppSpacing.sm,
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  currentNgo?.logoUrl != null && currentNgo!.logoUrl!.isNotEmpty
                  ? (currentNgo.logoUrl!.startsWith('data:image')
                        ? Image.memory(
                            dart_convert.base64Decode(
                              currentNgo.logoUrl!.split(',').last,
                            ),
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: currentNgo.logoUrl!,
                            fit: BoxFit.cover,
                          ))
                  : Image.asset(AppConstants.logoPath, fit: BoxFit.contain),
            ),
          ),
          if (expanded) ...[
            AppSpacing.hGapSm,
            Expanded(
              child: Text(
                currentNgo?.name ?? 'HRAS',
                style: AppTextStyles.titleMedium(
                  color: Theme.of(context).primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Toggle sidebar
            InkWell(
              onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
              borderRadius: AppTokens.borderRadiusSm,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  Icons.menu_open_rounded,
                  size: AppTokens.iconSm,
                  color: isDark
                      ? AppColors.darkTextHint
                      : AppColors.lightTextHint,
                ),
              ),
            ),
          ],
          if (!expanded)
            InkWell(
              onTap: () => setState(() => _sidebarExpanded = true),
              borderRadius: AppTokens.borderRadiusSm,
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(_SidebarItem item, bool isDark, bool expanded) {
    final isActive = widget.currentIndex == item.index;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final bgColor = isActive
        ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
        : Colors.transparent;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? AppSpacing.sm : AppSpacing.xs,
        vertical: 2,
      ),
      child: Material(
        color: bgColor,
        borderRadius: AppTokens.borderRadiusMd,
        child: InkWell(
          onTap: () => widget.onIndexChanged(item.index),
          borderRadius: AppTokens.borderRadiusMd,
          hoverColor: activeColor.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? AppSpacing.md : 0,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: AppTokens.iconMd,
                  color: isActive ? activeColor : inactiveColor,
                ),
                if (expanded) ...[
                  AppSpacing.hGapMd,
                  Text(
                    item.label,
                    style: AppTextStyles.bodyMedium(
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                  if (isActive) ...[
                    const Spacer(),
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: AppTokens.borderRadiusPill,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, bool isWide) {
    final items = _items;
    final currentLabel =
        items.where((i) => i.index == widget.currentIndex).isNotEmpty
        ? items.firstWhere((i) => i.index == widget.currentIndex).label
        : 'Dashboard';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      color: isDark ? AppColors.darkCardBg : Colors.white,
      child: Row(
        children: [
          // Breadcrumb
          Text(currentLabel, style: AppTextStyles.titleMedium()),
          const Spacer(),
          // Theme / notifications area
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              size: AppTokens.iconMd,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _buildUserFooter(bool isDark, bool expanded) {
    return Container(
      padding: EdgeInsets.all(expanded ? AppSpacing.md : AppSpacing.sm),
      child: expanded
          ? Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : 'U',
                    style: AppTextStyles.labelLarge(color: AppColors.primary),
                  ),
                ),
                AppSpacing.hGapSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.userName,
                        style: AppTextStyles.labelSmall(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.isAdmin ? 'Admin' : 'Volunteer',
                        style: AppTextStyles.caption(
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.lightTextHint,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onLogout,
                  borderRadius: AppTokens.borderRadiusSm,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      Icons.logout_rounded,
                      size: AppTokens.iconSm,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: InkWell(
                onTap: widget.onLogout,
                borderRadius: AppTokens.borderRadiusSm,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.logout_rounded,
                    size: AppTokens.iconSm,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final int index;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
