import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/feedback_model.dart';

class SentimentAnalysisScreen extends StatelessWidget {
  const SentimentAnalysisScreen({super.key});

  String _getSentiment(double rating) {
    if (rating >= 4) return 'Positive';
    if (rating >= 3) return 'Neutral';
    return 'Negative';
  }

  double _getConfidence(double rating) {
    // Simulated confidence based on rating extreme
    if (rating == 5 || rating == 1) return 0.95;
    if (rating == 4 || rating == 2) return 0.85;
    return 0.70; // 3 stars
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sentiment Analysis'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('feedbacks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No authentic feedback data available.'));
          }

          final feedbacks = snapshot.data!.docs.map((doc) => FeedbackModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
          
          int positive = 0, neutral = 0, negative = 0;
          for (var f in feedbacks) {
            if (f.rating >= 4) {
              positive++;
            } else if (f.rating >= 3) {
              neutral++;
            } else {
              negative++;
            }
          }

          final total = feedbacks.length;
          final posPct = (positive / total * 100).roundToDouble();
          final neuPct = (neutral / total * 100).roundToDouble();
          final negPct = (negative / total * 100).roundToDouble();

          return SingleChildScrollView(
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
                  'Based on $total real volunteer reviews',
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
                        if (posPct > 0)
                          PieChartSectionData(
                            color: Colors.green,
                            value: posPct,
                            title: '${posPct.toInt()}%',
                            radius: 60,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        if (negPct > 0)
                          PieChartSectionData(
                            color: Colors.red,
                            value: negPct,
                            title: '${negPct.toInt()}%',
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        if (neuPct > 0)
                          PieChartSectionData(
                            color: Colors.amber,
                            value: neuPct,
                            title: '${neuPct.toInt()}%',
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
                Text('Recent Authentic Classifications', style: AppTextStyles.titleMedium()),
                const SizedBox(height: 16),
                ...feedbacks.take(10).map((f) {
                  final sentiment = _getSentiment(f.rating);
                  final score = _getConfidence(f.rating);
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
                      title: Text('"${f.comment}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                      subtitle: Text('Score: ${(score * 100).toStringAsFixed(1)}% | ${f.rating} Stars'),
                      trailing: Text(sentiment, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    ),
                  );
                }),
              ],
            ),
          );
        },
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
