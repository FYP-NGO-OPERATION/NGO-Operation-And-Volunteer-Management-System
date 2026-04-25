import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/photo_model.dart';
import '../../models/campaign_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/gallery_service.dart';
import '../../config/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'full_screen_photo_viewer.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final CampaignModel campaign;

  const PhotoGalleryScreen({super.key, required this.campaign});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final GalleryService _galleryService = GalleryService();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    
    // Show dialog to choose source
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    // Optional: Ask for a caption
    String caption = '';
    if (!mounted) return;
    final captionResult = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Add Caption'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'e.g., Food distribution at Camp A'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, ''), child: const Text('Skip')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (captionResult != null) {
      caption = captionResult;
    }

    // Capture context-dependent values before async operations
    // ignore: use_build_context_synchronously — user captured before async gap
    final user = context.read<AuthProvider>().user!;

    setState(() => _isUploading = true);

    try {
      await _galleryService.uploadPhoto(
        campaignId: widget.campaign.id,
        imageFile: File(pickedFile.path),
        caption: caption,
        uploadedBy: user.uid,
        uploaderName: user.name,
      );
      if (mounted) SnackbarHelper.showSuccess(context, 'Photo uploaded successfully!');
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, 'Failed to upload photo: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _confirmDelete(PhotoModel photo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to permanently delete this photo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _galleryService.deletePhoto(photo);
        if (mounted) SnackbarHelper.showInfo(context, 'Photo deleted');
      } catch (e) {
        if (mounted) SnackbarHelper.showError(context, 'Failed to delete photo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: AppColors.primarySurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.campaign.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Campaign Photos & Memories',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (_isUploading)
            const LinearProgressIndicator(color: AppColors.primary),
          
          Expanded(
            child: StreamBuilder<List<PhotoModel>>(
              stream: _galleryService.getCampaignPhotos(widget.campaign.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final photos = snapshot.data ?? [];

                if (photos.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.photo_library_outlined,
                    title: 'No Photos Yet',
                    subtitle: isAdmin
                        ? 'Tap the camera button below to upload the first photo.'
                        : 'No photos have been uploaded for this campaign yet.',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenPhotoViewer(
                              imageUrl: photo.imageUrl,
                              caption: photo.caption,
                              uploaderName: photo.uploaderName,
                            ),
                          ),
                        );
                      },
                      onLongPress: isAdmin ? () => _confirmDelete(photo) : null,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: photo.imageUrl,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: photo.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.error, color: AppColors.error),
                                ),
                              ),
                            ),
                          ),
                          if (isAdmin)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _confirmDelete(photo),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_a_photo),
            )
          : null,
    );
  }
}
