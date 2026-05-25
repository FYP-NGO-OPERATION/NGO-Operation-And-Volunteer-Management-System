import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

class PredictiveDashboardScreen extends StatefulWidget {
  const PredictiveDashboardScreen({super.key});

  @override
  State<PredictiveDashboardScreen> createState() => _PredictiveDashboardScreenState();
}

class _PredictiveDashboardScreenState extends State<PredictiveDashboardScreen> {
  // Simulated AI Data
  final List<Map<String, dynamic>> _predictions = [
    {
      'region': 'Lahore (Urban)',
      'riskType': 'Urban Flooding',
      'riskScore': 85, // out of 100
      'confidence': 92,
      'recommendedTents': 250,
      'recommendedFoodKits': 1000,
      'eta': '24-48 Hours',
    },
    {
      'region': 'Karachi (South)',
      'riskType': 'Heatwave',
      'riskScore': 75,
      'confidence': 88,
      'recommendedTents': 0,
      'recommendedFoodKits': 500, // Water bottles equivalent
      'eta': '3-5 Days',
    },
    {
      'region': 'Swat Valley',
      'riskType': 'Landslide',
      'riskScore': 60,
      'confidence': 70,
      'recommendedTents': 100,
      'recommendedFoodKits': 300,
      'eta': '7+ Days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Predictive Analytics', style: AppTextStyles.titleLarge()),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePaddingWide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isDark),
            AppSpacing.vGapLg,
            _buildChartSection(isDark),
            AppSpacing.vGapLg,
            Text('High-Risk Regions', style: AppTextStyles.headlineMedium(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            AppSpacing.vGapMd,
            ..._predictions.map((p) => _buildPredictionCard(p, isDark)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, size: 48, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Resource Engine', style: AppTextStyles.titleLarge(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                const SizedBox(height: 4),
                Text(
                  'Analyzing historical weather, geographic vulnerabilities, and past relief data to forecast upcoming supply demands.',
                  style: AppTextStyles.bodyMedium(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(bool isDark) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('7-Day Demand Forecast (Food Kits)', style: AppTextStyles.titleMedium(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 100),
                      FlSpot(1, 150),
                      FlSpot(2, 400), // Spike!
                      FlSpot(3, 800), // Spike!
                      FlSpot(4, 300),
                      FlSpot(5, 200),
                      FlSpot(6, 150),
                    ],
                    isCurved: true,
                    color: AppColors.error,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: AppColors.error.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(Map<String, dynamic> data, bool isDark) {
    Color riskColor;
    if (data['riskScore'] > 80) riskColor = AppColors.error;
    else if (data['riskScore'] > 50) riskColor = AppColors.warning;
    else riskColor = AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: riskColor, width: 6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['region'], style: AppTextStyles.titleLarge(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${data['riskScore']}% Risk', style: TextStyle(color: riskColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Hazard: ${data['riskType']} | ETA: ${data['eta']}', style: AppTextStyles.bodyMedium(color: riskColor)),
            const Divider(height: 24),
            Text('AI Recommendation (Confidence: ${data['confidence']}%):', style: AppTextStyles.labelLarge(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (data['recommendedTents'] > 0)
                  _buildResourceBadge(Icons.home_filled, '${data['recommendedTents']} Tents'),
                const SizedBox(width: 8),
                if (data['recommendedFoodKits'] > 0)
                  _buildResourceBadge(Icons.fastfood, '${data['recommendedFoodKits']} Food Kits'),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Auto-Drafting Campaign from Prediction...')),
                  );
                },
                icon: const Icon(Icons.add_task),
                label: const Text('Draft Campaign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.lightTextPrimary)),
        ],
      ),
    );
  }
}
