import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../models/banner_model.dart';
import '../../services/banner_service.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../theme/app_text_styles.dart';
import '../../config/app_colors.dart';

class AdminBannerManagementScreen extends StatefulWidget {
  const AdminBannerManagementScreen({super.key});

  @override
  State<AdminBannerManagementScreen> createState() => _AdminBannerManagementScreenState();
}

class _AdminBannerManagementScreenState extends State<AdminBannerManagementScreen> {
  final BannerService _bannerService = BannerService();
  bool _isLoading = false;

  Future<void> _addBanner() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    
    try {
      final imageUrl = await CloudinaryService.uploadImage(File(image.path));
      if (imageUrl != null) {
        final newBanner = BannerModel(
          id: _bannerService.generateId(),
          imageUrl: imageUrl,
          targetType: 'none',
          createdAt: DateTime.now(),
        );
        await _bannerService.createBanner(newBanner);
        if (mounted) SnackbarHelper.showSuccess(context, 'Banner uploaded successfully');
      } else {
        if (mounted) SnackbarHelper.showError(context, 'Failed to upload image');
      }
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, 'Error uploading banner: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _editBannerDetails(BannerModel banner) {
    String type = banner.targetType;
    final idController = TextEditingController(text: banner.targetId);
    final urlController = TextEditingController(text: banner.targetUrl);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Edit Banner Link'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: type,
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('No Link')),
                        DropdownMenuItem(value: 'campaign', child: Text('Internal Campaign')),
                        DropdownMenuItem(value: 'session', child: Text('Virtual Session')),
                        DropdownMenuItem(value: 'external', child: Text('External URL (e.g. YouTube/Insta)')),
                      ],
                      onChanged: (val) {
                        setStateSB(() => type = val ?? 'none');
                      },
                      decoration: const InputDecoration(labelText: 'Link Type'),
                    ),
                    const SizedBox(height: 16),
                    if (type == 'campaign' || type == 'session')
                      TextField(
                        controller: idController,
                        decoration: InputDecoration(labelText: type == 'campaign' ? 'Campaign ID' : 'Session ID'),
                      ),
                    if (type == 'external')
                      TextField(
                        controller: urlController,
                        decoration: const InputDecoration(labelText: 'External URL (https://...)'),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedBanner = BannerModel(
                      id: banner.id,
                      imageUrl: banner.imageUrl,
                      targetType: type,
                      targetId: (type == 'campaign' || type == 'session') ? idController.text : null,
                      targetUrl: type == 'external' ? urlController.text : null,
                      isActive: banner.isActive,
                      sortOrder: banner.sortOrder,
                      createdAt: banner.createdAt,
                    );
                    await _bannerService.updateBanner(updatedBanner);
                    if (context.mounted) {
                      Navigator.pop(context);
                      SnackbarHelper.showSuccess(context, 'Banner updated');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: _isLoading ? null : _addBanner,
          )
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<BannerModel>>(
            stream: _bannerService.getAllBanners(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final banners = snapshot.data ?? [];
              if (banners.isEmpty) {
                return const Center(child: Text('No banners found. Upload one!'));
              }

              return ReorderableListView.builder(
                itemCount: banners.length,
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = banners.removeAt(oldIndex);
                  banners.insert(newIndex, item);
                  
                  // Update all sort orders
                  for (int i = 0; i < banners.length; i++) {
                    await _bannerService.updateSortOrder(banners[i].id, i);
                  }
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Card(
                    key: ValueKey(banner.id),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: SizedBox(
                        width: 80,
                        child: CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text('Link: ${banner.targetType.toUpperCase()}'),
                      subtitle: Text(
                        banner.targetType == 'external' ? (banner.targetUrl ?? 'No URL') :
                        (banner.targetType != 'none' ? (banner.targetId ?? 'No ID') : 'None')
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: banner.isActive,
                            onChanged: (val) => _bannerService.toggleBannerStatus(banner.id, val),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editBannerDetails(banner),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Banner?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                )
                              );
                              if (confirm == true) {
                                await _bannerService.deleteBanner(banner.id);
                              }
                            },
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
