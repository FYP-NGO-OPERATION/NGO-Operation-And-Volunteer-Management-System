import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/banner_model.dart';
import '../../services/banner_service.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/snackbar_helper.dart';
import '../../config/app_colors.dart';

class AdminBannerManagementScreen extends StatefulWidget {
  const AdminBannerManagementScreen({super.key});

  @override
  State<AdminBannerManagementScreen> createState() =>
      _AdminBannerManagementScreenState();
}

class _AdminBannerManagementScreenState
    extends State<AdminBannerManagementScreen> {
  final BannerService _bannerService = BannerService();
  bool _isLoading = false;

  Future<void> _addBanner() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (!mounted) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Banner',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Banner', aspectRatioLockEnabled: true),
      ],
    );

    if (croppedFile == null) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = await CloudinaryService.uploadImage(
        File(croppedFile.path),
      );
      if (imageUrl != null) {
        final newBanner = BannerModel(
          id: _bannerService.generateId(),
          imageUrl: imageUrl,
          targetType: 'none',
          createdAt: DateTime.now(),
        );
        await _bannerService.createBanner(newBanner);
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Banner uploaded successfully');
        }
      } else {
        if (mounted) {
          SnackbarHelper.showError(context, 'Failed to upload image');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error uploading banner: $e');
      }
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
                      isExpanded: true,
                      initialValue: type,
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('No Link')),
                        DropdownMenuItem(
                          value: 'campaign',
                          child: Text('Internal Campaign'),
                        ),
                        DropdownMenuItem(
                          value: 'session',
                          child: Text('Virtual Session'),
                        ),
                        DropdownMenuItem(
                          value: 'external',
                          child: Text('External URL'),
                        ),
                      ],
                      onChanged: (val) {
                        setStateSB(() => type = val ?? 'none');
                      },
                      decoration: const InputDecoration(labelText: 'Link Type'),
                    ),
                    const SizedBox(height: 16),
                    if (type == 'campaign')
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('campaigns')
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final docs = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: docs.any((d) => d.id == idController.text)
                                ? idController.text
                                : null,
                            hint: const Text('Select Campaign'),
                            items: docs
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d.id,
                                    child: Text(d['title'] ?? 'Unknown'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => idController.text = val ?? '',
                          );
                        },
                      ),
                    if (type == 'session')
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('virtual_sessions')
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final docs = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: docs.any((d) => d.id == idController.text)
                                ? idController.text
                                : null,
                            hint: const Text('Select Session'),
                            items: docs
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d.id,
                                    child: Text(d['title'] ?? 'Unknown'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => idController.text = val ?? '',
                          );
                        },
                      ),
                    if (type == 'external')
                      TextField(
                        controller: urlController,
                        decoration: const InputDecoration(
                          labelText: 'External URL (https://...)',
                        ),
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
                      targetId: (type == 'campaign' || type == 'session')
                          ? idController.text
                          : null,
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
          },
        );
      },
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
          ),
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
                return const Center(
                  child: Text('No banners found. Upload one!'),
                );
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 80,
                              height: 50,
                              child: CachedNetworkImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Link: ${banner.targetType.toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  banner.targetType == 'external'
                                      ? (banner.targetUrl ?? 'No URL')
                                      : (banner.targetType != 'none'
                                            ? (banner.targetId ?? 'No ID')
                                            : 'None'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: banner.isActive,
                                onChanged: (val) => _bannerService
                                    .toggleBannerStatus(banner.id, val),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _editBannerDetails(banner);
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Banner?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _bannerService.deleteBanner(
                                        banner.id,
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.drag_handle, color: Colors.grey),
                            ],
                          ),
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
