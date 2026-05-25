import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SentimentAnalysisScreen extends StatelessWidget {
  const SentimentAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final mockFeedbacks = [
      {'text': 'Amazing experience volunteering at the flood relief camp!', 'sentiment': 'Positive', 'score': 0.92},
      {'text': 'The management was a bit chaotic, we needed more water.', 'sentiment': 'Negative', 'score': -0.45},
      {'text': 'I attended the food drive. It was okay.', 'sentiment': 'Neutral', 'score': 0.05},
      {'text': 'Loved the energy of the team! Great work HRAS.', 'sentiment': 'Positive', 'score': 0.88},
      {'text': 'We waited for 2 hours and no one guided us.', 'sentiment': 'Negative', 'score': -0.75},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sentiment Analysis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Volunteer Feedback Mood',
              style: AppTextStyles.titleLarge(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by Natural Language Processing',
              style: AppTextStyles.bodyMedium(color: Colors.blueGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: 60,
                      title: '60%',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: 25,
                      title: '25%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.amber,
                      value: 15,
                      title: '15%',
                      radius: 40,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Positive'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.amber, 'Neutral'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.red, 'Negative'),
              ],
            ),
            const SizedBox(height: 32),
            Text('Recent Feedback Classifications', style: AppTextStyles.titleMedium()),
            const SizedBox(height: 16),
            ...mockFeedbacks.map((f) {
              final sentiment = f['sentiment'] as String;
              final score = f['score'] as double;
              final Color color = sentiment == 'Positive' 
                  ? Colors.green 
                  : (sentiment == 'Negative' ? Colors.red : Colors.amber);
              final IconData icon = sentiment == 'Positive' 
                  ? Icons.sentiment_very_satisfied
                  : (sentiment == 'Negative' ? Icons.sentiment_very_dissatisfied : Icons.sentiment_neutral);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(icon, color: color),
                  ),
                  title: Text('"${f['text']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                  subtitle: Text('Confidence Score: ${(score.abs() * 100).toStringAsFixed(1)}%'),
                  trailing: Text(sentiment, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
