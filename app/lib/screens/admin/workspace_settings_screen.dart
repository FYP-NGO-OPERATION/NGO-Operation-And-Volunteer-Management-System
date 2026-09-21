import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../providers/ngo_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class WorkspaceSettingsScreen extends StatefulWidget {
  const WorkspaceSettingsScreen({super.key});

  @override
  State<WorkspaceSettingsScreen> createState() =>
      _WorkspaceSettingsScreenState();
}

class _WorkspaceSettingsScreenState extends State<WorkspaceSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _welcomeController;
  late TextEditingController _missionController;
  late TextEditingController _websiteController;

  Color _primaryColor = AppColors.primary;
  Color _secondaryColor = AppColors.secondary;

  String? _logoUrl;
  String? _bannerUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final ngo = Provider.of<NgoProvider>(context, listen: false).currentNgo;

    _nameController = TextEditingController(text: ngo?.name ?? '');
    _descController = TextEditingController(text: ngo?.description ?? '');
    _welcomeController = TextEditingController(text: ngo?.welcomeText ?? '');
    _missionController = TextEditingController(
      text: ngo?.missionStatement ?? '',
    );
    _websiteController = TextEditingController(text: ngo?.websiteUrl ?? '');

    _logoUrl = ngo?.logoUrl;
    _bannerUrl = ngo?.bannerUrl;

    if (ngo?.primaryColorHex != null && ngo!.primaryColorHex.isNotEmpty) {
      _primaryColor = _hexToColor(ngo.primaryColorHex);
    }
    if (ngo?.secondaryColorHex != null && ngo!.secondaryColorHex!.isNotEmpty) {
      _secondaryColor = _hexToColor(ngo.secondaryColorHex!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _welcomeController.dispose();
    _missionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Color _hexToColor(String code) {
    var str = code.replaceAll('#', '');
    if (str.length == 6) str = 'FF$str';
    return Color(int.tryParse(str, radix: 16) ?? 0xFF1A6B3C);
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final ngoId = Provider.of<NgoProvider>(
          context,
          listen: false,
        ).currentNgo?.id;
        if (ngoId == null) throw Exception("No NGO selected");

        final ref = FirebaseStorage.instance.ref().child(
          'ngos/$ngoId/${isLogo ? 'logo' : 'banner'}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        await ref.putFile(File(pickedFile.path));
        final url = await ref.getDownloadURL();

        setState(() {
          if (isLogo) {
            _logoUrl = url;
          } else {
            _bannerUrl = url;
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _pickColor(bool isPrimary) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = isPrimary ? _primaryColor : _secondaryColor;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                setState(() {
                  if (isPrimary) {
                    _primaryColor = tempColor;
                  } else {
                    _secondaryColor = tempColor;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final ngo = Provider.of<NgoProvider>(context, listen: false).currentNgo;
    if (ngo == null) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'welcomeText': _welcomeController.text.trim(),
      'missionStatement': _missionController.text.trim(),
      'websiteUrl': _websiteController.text.trim(),
      'primaryColorHex': _colorToHex(_primaryColor),
      'secondaryColorHex': _colorToHex(_secondaryColor),
      'logoUrl': _logoUrl,
      'bannerUrl': _bannerUrl,
    };

    final success = await Provider.of<NgoProvider>(
      context,
      listen: false,
    ).updateNgoProfile(ngo.id, data);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workspace Settings Updated!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update settings.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngo = Provider.of<NgoProvider>(context).currentNgo;

    if (ngo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workspace Settings')),
        body: const Center(child: Text('No active workspace.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace Settings'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Branding & Media', style: AppTextStyles.titleMedium()),
              const SizedBox(height: 16),

              // Images
              Row(
                children: [
                  Expanded(
                    child: _ImagePickerBox(
                      title: 'Workspace Logo',
                      imageUrl: _logoUrl,
                      onTap: () => _pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ImagePickerBox(
                      title: 'Hero Banner',
                      imageUrl: _bannerUrl,
                      onTap: () => _pickImage(false),
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Colors
              Text('Theme Colors', style: AppTextStyles.titleMedium()),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ColorPickerBox(
                      title: 'Primary Color',
                      color: _primaryColor,
                      onTap: () => _pickColor(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ColorPickerBox(
                      title: 'Secondary Color',
                      color: _secondaryColor,
                      onTap: () => _pickColor(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Texts
              Text('Identity & Content', style: AppTextStyles.titleMedium()),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'NGO Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _welcomeController,
                decoration: const InputDecoration(
                  labelText: 'Dashboard Welcome Text',
                  hintText: 'e.g. Welcome to our Mission!',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _missionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mission Statement',
                  hintText: 'Displayed on dashboard to inspire volunteers.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveSettings,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Save Workspace Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback onTap;
  final double aspectRatio;

  const _ImagePickerBox({
    required this.title,
    this.imageUrl,
    required this.onTap,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelLarge()),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? const Center(
                      child: Icon(Icons.add_a_photo, color: Colors.grey),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorPickerBox extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ColorPickerBox({
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelLarge()),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
          ),
        ),
      ],
    );
  }
}
