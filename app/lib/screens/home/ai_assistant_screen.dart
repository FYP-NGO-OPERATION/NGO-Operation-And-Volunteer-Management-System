import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/gemini_config_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late final GenerativeModel _model;
  late ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    final ngoId = Provider.of<AuthProvider>(context, listen: false).user?.currentNgoId ?? 'HRAS_DEFAULT_ID';
    final apiKey = await GeminiConfigService.getApiKey(ngoId);
    _model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
          'You are HRAS Assistant, a helpful AI guide for NGO volunteers. Keep your answers concise, empathetic, and relevant to volunteering, emergency response, and social work. Answer in the language the user speaks (Urdu or English).'),
    );
    _chatSession = _model.startChat();
    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': 'Hello! I am your HRAS AI Assistant. How can I help you today? (e.g. "What to do in an earthquake?")'
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'text': response.text ?? 'Sorry, I could not understand that.'});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'text': 'Raw Error: $e'});
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('ai_assistant'.tr(), style: AppTextStyles.titleLarge()),
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
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? AppColors.primary 
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isUser 
                            ? Colors.white 
                            : (isDark ? Colors.white : Colors.black87),
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
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
