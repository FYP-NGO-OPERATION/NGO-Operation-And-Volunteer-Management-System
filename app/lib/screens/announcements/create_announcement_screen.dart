import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/announcement_service.dart';
import '../../config/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _announcementService = AnnouncementService();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user!;
      
      final announcement = AnnouncementModel(
        id: '',
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        authorId: user.uid,
        authorName: user.name,
        createdAt: DateTime.now(),
      );

      await _announcementService.createAnnouncement(announcement);

      if (!mounted) return;
      SnackbarHelper.showSuccess(context, 'Announcement posted successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Failed to post announcement');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.campaign, color: AppColors.primary, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'This announcement will be visible to all volunteers on their dashboard.',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g., Important Update on Winter Drive',
                prefixIcon: Icons.title,
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _messageController,
                label: 'Message',
                hint: 'Write your full announcement here...',
                prefixIcon: Icons.message,
                maxLines: 6,
                validator: (v) => v == null || v.trim().isEmpty ? 'Message is required' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Post Announcement',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
