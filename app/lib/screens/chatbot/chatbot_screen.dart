import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../services/gemini_config_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late final GenerativeModel _model;
  // Real AI mode active for FYP presentation
  final bool _useMockAI = false; 

  @override
  void initState() {
    super.initState();
    _initializeModel();
    
    // Initial greeting
    _messages.add(ChatMessage(
      text: "Hello! I am your AI Assistant. How can I help you with campaigns, donations, or volunteer guidelines today?", 
      isUser: false
    ));
  }

  Future<void> _initializeModel() async {
    if (!_useMockAI) {
      final ngoId = Provider.of<AuthProvider>(context, listen: false).user?.currentNgoId ?? 'HRAS_DEFAULT_ID';
      final apiKey = await GeminiConfigService.getApiKey(ngoId);
      _model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: apiKey);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    try {
      String responseText = '';
      if (_useMockAI) {
        // Mock AI logic for FYP presentation
        await Future.delayed(const Duration(seconds: 2));
        if (text.toLowerCase().contains('campaign')) {
          responseText = "We currently have 3 active campaigns: Education Drive, Flood Relief, and Food Distribution. Would you like to see them?";
        } else if (text.toLowerCase().contains('blood')) {
          responseText = "You can register your blood group in your profile. If there's an emergency, the admin will notify you immediately.";
        } else if (text.toLowerCase().contains('urdu')) {
          responseText = "جی ہاں، میں اردو میں بھی بات کر سکتا ہوں۔ آپ کو کس قسم کی مدد چاہیے؟";
        } else {
          responseText = "That's a great question! As an AI, I suggest checking the 'Campaigns' tab for more active opportunities.";
        }
      } else {
        // Real Gemini API call
        final content = [Content.text(text)];
        final response = await _model.generateContent(content);
        responseText = response.text ?? 'Sorry, I could not generate a response.';
      }

      setState(() {
        _messages.add(ChatMessage(text: responseText, isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error: Could not reach AI service.", isUser: false));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            AppSpacing.hGapSm,
            const Text('AI Assistant'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser 
                          ? AppColors.primary 
                          : (isDark ? AppColors.darkSurface : Colors.grey.shade200),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
                        bottomRight: Radius.circular(msg.isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('AI is typing...'),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask anything...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
