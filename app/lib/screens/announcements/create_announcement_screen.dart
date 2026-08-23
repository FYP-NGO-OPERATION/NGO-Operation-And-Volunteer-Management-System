import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/announcement_service.dart';
import '../../config/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/cloudinary_service.dart';
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
  final _videoUrlController = TextEditingController();
  final _announcementService = AnnouncementService();
  bool _isLoading = false;
  File? _selectedImage;
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

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
      
      String? uploadedImageUrl;
      if (_selectedImage != null) {
        uploadedImageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      }

      final announcement = AnnouncementModel(
        id: '',
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        authorId: user.uid,
        authorName: user.name,
        imageUrl: uploadedImageUrl,
        videoUrl: _videoUrlController.text.trim().isNotEmpty ? _videoUrlController.text.trim() : null,
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
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: AppColors.primary),
                            SizedBox(height: 8),
                            Text('Attach Image (Optional)', style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                ),
              ),
              if (_selectedImage != null)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  label: const Text('Remove Image', style: TextStyle(color: AppColors.error)),
                ),
              const SizedBox(height: 16),
              const Text('Or / And', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _videoUrlController,
                label: 'Reference Video Link (Optional)',
                hint: 'e.g., https://youtube.com/...',
                prefixIcon: Icons.video_library,
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
