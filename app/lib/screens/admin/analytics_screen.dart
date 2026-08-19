import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/campaign_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../utils/responsive.dart';
import '../../services/pdf_report_service.dart';
import '../../enums/app_enums.dart';
import '../../models/campaign_model.dart';
import '../../providers/ngo_provider.dart';
import '../../services/csv_export_service.dart';
import 'components/ai_insights_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isMobile(context) ? AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          Consumer<CampaignProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.table_chart, color: AppColors.success),
                    tooltip: 'export_csv'.tr(),
                    onPressed: () {
                      CsvExportService.exportCampaignsToCsv(context, provider.allCampaigns);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                    tooltip: 'Download PDF Report',
                    onPressed: () async {
                      try {
                        final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
                        final ngoId = ngoProvider.currentNgo?.id;
                        if (ngoId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating PDF...')));
                          await PdfReportService.generateAndDownloadReport(ngoId: ngoId);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to generate PDF: $e'),
                            backgroundColor: AppColors.error,
                          ));
                        }
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ) : null,
      body: Consumer<CampaignProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allCampaigns.isEmpty) {
            return const Center(child: Text('No data available for analytics.'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.isDesktop(context) ? AppSpacing.xl : AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(provider, context),
                AppSpacing.vGapXl,
                AiInsightsCard(
                  totalCampaigns: provider.totalCampaigns,
                  totalVolunteers: provider.allCampaigns.fold(0, (sum, c) => sum + c.totalVolunteers),
                  totalFunds: provider.totalDonationsOverall,
                ),
                AppSpacing.vGapXl,
                // Desktop: charts side by side
                if (Responsive.isDesktop(context))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Campaigns by Status', style: AppTextStyles.titleLarge()),
                            AppSpacing.vGapLg,
                            _buildCampaignStatusBarChart(provider),
                          ],
                        ),
                      ),
                      AppSpacing.hGapXl,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Campaign Success Rate', style: AppTextStyles.titleLarge()),
                            AppSpacing.vGapLg,
                            _buildSuccessRateChart(provider),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  Text('Campaigns by Status', style: AppTextStyles.titleLarge()),
                  AppSpacing.vGapLg,
                  _buildCampaignStatusBarChart(provider),
                  AppSpacing.vGapXxl,
                  Text('Campaign Success Rate', style: AppTextStyles.titleLarge()),
                  AppSpacing.vGapLg,
                  _buildSuccessRateChart(provider),
                ],
                AppSpacing.vGapXxl,
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatCompact(double number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(1)}Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toStringAsFixed(0);
  }

  Widget _buildSummaryCards(CampaignProvider provider, BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final cards = [
      _summaryCard('Total Campaigns', '${provider.totalCampaigns}', Icons.campaign, AppColors.primary),
      _summaryCard('Volunteers', '${provider.allCampaigns.fold(0, (sum, c) => sum + c.totalVolunteers)}', Icons.people, AppColors.info),
      _summaryCard('Funds Raised', 'Rs.${_formatCompact(provider.totalDonationsOverall)}', Icons.volunteer_activism, AppColors.success),
      if (isDesktop) _summaryCard('Beneficiaries', '${provider.totalBeneficiariesOverall}+', Icons.family_restroom, AppColors.accent),
    ];

    if (isDesktop) {
      return Row(
        children: cards.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: e.key > 0 ? AppSpacing.md : 0),
              child: e.value,
            ),
          );
        }).toList(),
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 12),
        Expanded(child: cards[1]),
        const SizedBox(width: 12),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppTokens.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: AppTokens.iconMd),
          ),
          AppSpacing.vGapSm,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.statValue(color: color)),
          ),
          AppSpacing.vGapXs,
          Text(title, style: AppTextStyles.caption(color: color)),
        ],
      ),
    );
  }

  Widget _buildCampaignStatusBarChart(CampaignProvider provider) {
    int active = provider.activeCampaigns;
    int completed = provider.completedCampaigns;
    int upcoming = provider.upcomingCampaigns;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (provider.totalCampaigns + 2).toDouble(),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 2,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.round().toString(),
                      TextStyle(color: rod.color, fontWeight: FontWeight.bold, fontSize: 14),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      switch (value.toInt()) {
                        case 0: return const Text('Upcoming', style: TextStyle(fontSize: 12));
                        case 1: return const Text('Active', style: TextStyle(fontSize: 12));
                        case 2: return const Text('Completed', style: TextStyle(fontSize: 12));
                        default: return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(x: 0, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: upcoming.toDouble(), color: AppColors.info, width: 20, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 1, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: active.toDouble(), color: AppColors.success, width: 20, borderRadius: BorderRadius.circular(4))]),
                BarChartGroupData(x: 2, showingTooltipIndicators: [0], barRods: [BarChartRodData(toY: completed.toDouble(), color: AppColors.primary, width: 20, borderRadius: BorderRadius.circular(4))]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRateChart(CampaignProvider provider) {
    final completedCampaigns = provider.allCampaigns.where((c) => c.status == CampaignStatus.completed).toList();
    if (completedCampaigns.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No completed campaigns to evaluate.')),
      );
    }

    int successful = 0;
    int unsuccessful = 0;
    for (var c in completedCampaigns) {
      if (c.isSuccessful) successful++; else unsuccessful++;
    }

    final total = successful + unsuccessful;
    final succPct = (successful / total * 100).toStringAsFixed(1);
    final failPct = (unsuccessful / total * 100).toStringAsFixed(1);

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: successful.toDouble(),
                      color: AppColors.success,
                      title: '$succPct%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: unsuccessful.toDouble(),
                      color: AppColors.error,
                      title: '$failPct%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _indicator(color: AppColors.success, text: 'Successful ($successful)'),
                const SizedBox(height: 8),
                _indicator(color: AppColors.error, text: 'Unsuccessful ($unsuccessful)'),
              ],
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _indicator({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
