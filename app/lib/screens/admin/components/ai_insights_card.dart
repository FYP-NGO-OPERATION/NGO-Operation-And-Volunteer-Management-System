import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../config/app_colors.dart';

class AiInsightsCard extends StatefulWidget {
  final int totalCampaigns;
  final int totalVolunteers;
  final double totalFunds;

  const AiInsightsCard({
    super.key,
    required this.totalCampaigns,
    required this.totalVolunteers,
    required this.totalFunds,
  });

  @override
  State<AiInsightsCard> createState() => _AiInsightsCardState();
}

class _AiInsightsCardState extends State<AiInsightsCard> {
  String _insight = '';
  bool _isLoading = false;

  Future<void> _generateInsight() async {
    setState(() => _isLoading = true);
    try {
      const apiKey = 'AIzaSyDshO3oaKyZKT6wJGS17f21k2JPImZjCEw'; // Real API Key
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

      final prompt = '''
Act as an expert NGO strategist. Given our current platform data:
- Total Campaigns: ${widget.totalCampaigns}
- Total Volunteers: ${widget.totalVolunteers}
- Total Funds Raised: Rs. ${widget.totalFunds}

Write a short, engaging 3-sentence predictive insight. Predict the trend for next month and suggest one specific campaign focus area.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      
      if (mounted) {
        setState(() {
          _insight = response.text?.trim() ?? 'No insights generated.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _insight = 'Failed to generate AI insights: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('AI Predictive Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const Spacer(),
                if (!_isLoading)
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate'),
                    onPressed: _generateInsight,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_insight.isEmpty)
              const Text('Tap generate to get Gemini AI strategic predictions for next month.', style: TextStyle(color: Colors.grey))
            else
              Text(_insight, style: const TextStyle(fontSize: 15, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
