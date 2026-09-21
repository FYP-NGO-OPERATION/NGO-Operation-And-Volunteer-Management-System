import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_tokens.dart';
import '../../providers/ngo_provider.dart';
import '../../services/analytics_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  AnalyticsData? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
      final ngoId = ngoProvider.currentNgo?.id;
      if (ngoId == null) throw Exception("No NGO selected");

      final data = await _analyticsService.getNgoAnalytics(ngoId);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impact Metrics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            )
          : _data == null
          ? const Center(child: Text('No data available'))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCards(),
                    AppSpacing.vGapXl,
                    Text(
                      'Campaigns Overview',
                      style: AppTextStyles.titleLarge(),
                    ),
                    AppSpacing.vGapLg,
                    _buildPieChart(),
                    AppSpacing.vGapXl,
                    Text(
                      'Campaigns By Category',
                      style: AppTextStyles.titleLarge(),
                    ),
                    AppSpacing.vGapLg,
                    _buildBarChart(),
                    AppSpacing.vGapXxl,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.lg) / 2;
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            _statCard(
              'Total Campaigns',
              _data!.totalCampaigns.toString(),
              Icons.campaign,
              Colors.blue,
              width,
            ),
            _statCard(
              'Volunteers',
              _data!.totalVolunteers.toString(),
              Icons.people,
              Colors.green,
              width,
            ),
            _statCard(
              'Beneficiaries',
              _data!.totalBeneficiaries.toString(),
              Icons.favorite,
              Colors.red,
              width,
            ),
            _statCard(
              'Donations',
              'Rs. ${_data!.totalDonations.toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.amber,
              width,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double width,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusLg,
        boxShadow: AppTokens.shadowSoft,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          AppSpacing.vGapSm,
          Text(value, style: AppTextStyles.headlineMedium()),
          Text(
            title,
            style: AppTextStyles.bodySmall(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int active = _data!.activeCampaigns;
    int completed = _data!.completedCampaigns;
    int upcoming = _data!.totalCampaigns - (active + completed);

    if (_data!.totalCampaigns == 0) {
      return const Center(child: Text('No campaigns to display'));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusLg,
        boxShadow: AppTokens.shadowSoft,
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (active > 0)
                    PieChartSectionData(
                      color: Colors.green,
                      value: active.toDouble(),
                      title: '$active',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (completed > 0)
                    PieChartSectionData(
                      color: Colors.blue,
                      value: completed.toDouble(),
                      title: '$completed',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (upcoming > 0)
                    PieChartSectionData(
                      color: Colors.orange,
                      value: upcoming.toDouble(),
                      title: '$upcoming',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _indicator(Colors.green, 'Active'),
              AppSpacing.vGapSm,
              _indicator(Colors.blue, 'Completed'),
              AppSpacing.vGapSm,
              _indicator(Colors.orange, 'Upcoming'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildBarChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final map = _data!.campaignsByType;

    if (map.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    List<BarChartGroupData> barGroups = [];
    int x = 0;
    map.forEach((key, value) {
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: AppColors.primary,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      x++;
    });

    return Container(
      height: 300,
      padding: const EdgeInsetsDirectional.only(
        top: AppSpacing.xl,
        end: AppSpacing.xl,
        start: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusLg,
        boxShadow: AppTokens.shadowSoft,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: map.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= map.keys.length) return const Text('');
                  String title = map.keys.elementAt(value.toInt());
                  if (title.length > 8) title = '${title.substring(0, 6)}..';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(title, style: const TextStyle(fontSize: 10)),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
