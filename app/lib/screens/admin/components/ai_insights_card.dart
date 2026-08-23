import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../config/app_colors.dart';
import '../../../services/gemini_config_service.dart';
import '../ai_settings_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

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
  String? _error;
  bool _isLoading = false;

  Future<void> _generateInsight() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ngoId = Provider.of<AuthProvider>(context, listen: false).user?.currentNgoId ?? 'HRAS_DEFAULT_ID';

      final apiKey = await GeminiConfigService.getApiKey(ngoId);
      if (apiKey == null || apiKey.isEmpty) {
        setState(() => _error = 'AI API key is not configured.');
        return;
      }
      
      final model = GenerativeModel(
        model: 'gemini-3.6-flash',
        apiKey: apiKey,
      );

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
          _error = 'Failed to generate AI insights: $e';
          _insight = '';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Card(
      color: isDark ? AppColors.darkCardBg : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryColor.withValues(alpha: 0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('AI Predictive Insights', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_isLoading)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate'),
                    onPressed: _generateInsight,
                  ),
              ],
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AiSettingsScreen()));
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Configure AI API Key'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ],
              )
            else if (_insight.isEmpty)
              Text('Tap generate to get Gemini AI strategic predictions for next month.', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey))
            else
              Text(_insight, style: TextStyle(fontSize: 15, height: 1.4, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}
