import 'package:flutter/material.dart';
import '../../services/gemini_config_service.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _keyController = TextEditingController();
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentKey();
  }

  Future<void> _loadCurrentKey() async {
    try {
      final ngoId =
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).user?.currentNgoId ??
          'HRAS_DEFAULT_ID';

      final key = await GeminiConfigService.getApiKey(ngoId);
      if (mounted) {
        setState(() {
          _keyController.text = key;
        });
      }
    } catch (e) {
      // It's fine if it's not configured yet.
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  Future<void> _saveKey() async {
    final newKey = _keyController.text.trim();
    if (newKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('API Key cannot be empty')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ngoId =
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).user?.currentNgoId ??
          'HRAS_DEFAULT_ID';

      await GeminiConfigService.setApiKey(ngoId, newKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'AI Key saved successfully! AI features are now active.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save key: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gemini AI Configuration',
                    style: AppTextStyles.titleLarge(),
                  ),
                  AppSpacing.vGapMd,
                  Text(
                    'To prevent key leaks, the API key is not stored in the app code. '
                    'Enter your Gemini API key from Google AI Studio here. '
                    'This key will be securely stored in Firestore and used for all AI features like Chatbot, Receipt Scanner, and AI Insights.',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  AppSpacing.vGapXl,
                  TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'Gemini API Key',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
                  ),
                  AppSpacing.vGapXl,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveKey,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save & Activate AI'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
