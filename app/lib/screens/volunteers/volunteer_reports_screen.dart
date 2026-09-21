import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_animations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../services/volunteer_report_service.dart';
import 'package:fl_chart/fl_chart.dart';

class VolunteerReportsScreen extends StatefulWidget {
  const VolunteerReportsScreen({super.key});

  @override
  State<VolunteerReportsScreen> createState() => _VolunteerReportsScreenState();
}

class _VolunteerReportsScreenState extends State<VolunteerReportsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedTimeframe = 'Monthly';
  bool _isGenerating = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: AppAnimations.easeOut,
    );
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateAndPrintPdf() async {
    setState(() => _isGenerating = true);

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      setState(() => _isGenerating = false);
      return;
    }

    try {
      final pdfBytes = await VolunteerReportService.generateReport(
        user,
        timeframe: _selectedTimeframe,
      );
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Volunteer_Impact_Report_${user.name.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate report: $e')));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGenerating ? null : _generateAndPrintPdf,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: AppSpacing.pagePaddingWide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Timeframe Selector ---
                    _buildTimeframeSelector(isDark),
                    AppSpacing.vGapXl,

                    // --- Magical Overview Cards ---
                    Text(
                      '$_selectedTimeframe Overview',
                      style: AppTextStyles.headlineSmall(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    AppSpacing.vGapLg,
                    _buildDashboardCards(isDark),

                    AppSpacing.vGapXl,

                    // --- Chart Section ---
                    Text(
                      'Engagement Trends',
                      style: AppTextStyles.headlineSmall(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    AppSpacing.vGapLg,
                    _buildChart(isDark),

                    AppSpacing.vGapXl,

                    // --- Generate PDF Button ---
                    CustomButton(
                      text: 'Generate Professional PDF Report',
                      icon: Icons.download,
                      isLoading: _isGenerating,
                      onPressed: _generateAndPrintPdf,
                    ),
                    AppSpacing.vGapXl,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimeframeSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppTokens.borderRadiusLg,
        boxShadow: AppTokens.shadowSoft,
      ),
      child: Row(
        children: ['Weekly', 'Monthly', 'Yearly'].map((tf) {
          final isSelected = _selectedTimeframe == tf;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeframe = tf),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppTokens.borderRadiusLg,
                ),
                child: Center(
                  child: Text(
                    tf,
                    style:
                        AppTextStyles.labelLarge(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                        ).copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardCards(bool isDark) {
    int hours = _selectedTimeframe == 'Weekly'
        ? 12
        : (_selectedTimeframe == 'Monthly' ? 45 : 320);
    int tasks = _selectedTimeframe == 'Weekly'
        ? 3
        : (_selectedTimeframe == 'Monthly' ? 14 : 98);
    int impact = hours * 10 + tasks * 5;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('Hours Logged', '$hours', Icons.access_time, isDark),
        _buildStatCard('Tasks Done', '$tasks', Icons.task_alt, isDark),
        _buildStatCard('Campaigns', '2', Icons.campaign, isDark),
        _buildStatCard(
          'Impact Score',
          '$impact',
          Icons.star,
          isDark,
          highlight: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    bool isDark, {
    bool highlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppTokens.borderRadiusLg,
        border: highlight
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        boxShadow: highlight
            ? AppTokens.shadowGlow(AppColors.primary)
            : AppTokens.shadowSoft,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: highlight
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
              ),
              AppSpacing.hGapSm,
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Text(
            value,
            style: AppTextStyles.headlineLarge(
              color: highlight
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppTokens.borderRadiusXl,
        boxShadow: AppTokens.shadowSoft,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  );
                  String text = '';
                  switch (value.toInt()) {
                    case 0:
                      text = 'W1';
                      break;
                    case 1:
                      text = 'W2';
                      break;
                    case 2:
                      text = 'W3';
                      break;
                    case 3:
                      text = 'W4';
                      break;
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 8,
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 10,
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 14,
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 12,
                  color: AppColors.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
