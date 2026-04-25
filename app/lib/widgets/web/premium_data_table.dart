import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';

/// Premium reusable data table with search, pagination, and hover states.
/// Designed for admin web dashboard.
class PremiumDataTable<T> extends StatefulWidget {
  final List<T> data;
  final List<PremiumColumn<T>> columns;
  final String title;
  final String searchHint;
  final bool Function(T item, String query) searchFilter;
  final Widget? emptyState;
  final Widget? trailing;  // e.g. "Add User" button
  final int rowsPerPage;

  const PremiumDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.title,
    required this.searchFilter,
    this.searchHint = 'Search...',
    this.emptyState,
    this.trailing,
    this.rowsPerPage = 10,
  });

  @override
  State<PremiumDataTable<T>> createState() => _PremiumDataTableState<T>();
}

class _PremiumDataTableState<T> extends State<PremiumDataTable<T>> {
  String _query = '';
  int _currentPage = 0;
  int _hoveredRow = -1;

  List<T> get _filtered {
    if (_query.isEmpty) return widget.data;
    return widget.data.where((item) => widget.searchFilter(item, _query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;
    final totalPages = (filtered.length / widget.rowsPerPage).ceil();
    final pageItems = filtered.skip(_currentPage * widget.rowsPerPage).take(widget.rowsPerPage).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        boxShadow: AppTokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ───
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Text(widget.title, style: AppTextStyles.titleLarge()),
                const Spacer(),
                // Search
                SizedBox(
                  width: 260,
                  height: 40,
                  child: TextField(
                    onChanged: (v) => setState(() { _query = v; _currentPage = 0; }),
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: AppTokens.borderRadiusSm,
                        borderSide: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                      ),
                    ),
                    style: AppTextStyles.bodySmall(),
                  ),
                ),
                if (widget.trailing != null) ...[
                  AppSpacing.hGapMd,
                  widget.trailing!,
                ],
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

          // ─── Column Headers ───
          Container(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.neutral50,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: widget.columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Text(col.header, style: AppTextStyles.labelSmall(
                    color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint)),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),

          // ─── Rows ───
          if (pageItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.section),
              child: widget.emptyState ?? Center(
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48,
                      color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                    AppSpacing.vGapMd,
                    Text('No data found', style: AppTextStyles.bodyMedium(
                      color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint)),
                  ],
                ),
              ),
            )
          else
            ...pageItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredRow = idx),
                onExit: (_) => setState(() => _hoveredRow = -1),
                child: Container(
                  color: _hoveredRow == idx
                      ? (isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.primary.withValues(alpha: 0.02))
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Row(
                    children: widget.columns.map((col) {
                      return Expanded(
                        flex: col.flex,
                        child: col.builder(item),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),

          // ─── Pagination ───
          if (totalPages > 1) ...[
            Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${filtered.length} total • Page ${_currentPage + 1} of $totalPages',
                    style: AppTextStyles.caption(color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                        icon: const Icon(Icons.chevron_left, size: 20),
                        iconSize: 20,
                      ),
                      IconButton(
                        onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                        icon: const Icon(Icons.chevron_right, size: 20),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Column definition for PremiumDataTable
class PremiumColumn<T> {
  final String header;
  final Widget Function(T item) builder;
  final int flex;

  const PremiumColumn({
    required this.header,
    required this.builder,
    this.flex = 1,
  });
}
