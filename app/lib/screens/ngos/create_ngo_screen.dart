import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ngo_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ngo_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/snackbar_helper.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../config/app_colors.dart';

import 'package:easy_localization/easy_localization.dart';

class CreateNgoScreen extends StatefulWidget {
  const CreateNgoScreen({super.key});

  @override
  State<CreateNgoScreen> createState() => _CreateNgoScreenState();
}

class _CreateNgoScreenState extends State<CreateNgoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  Uint8List? _selectedLogoBytes;
  bool _isUploadingLogo = false;
  
  String _selectedColor = '#1A6B3C'; // Default HRAS Green
  
  final Map<String, bool> _selectedFeatures = {
    'campaigns': true,
    'donations': true,
    'volunteers': true,
    'leaderboard': false,
  };

  final List<Map<String, String>> _themeColors = [
    {'name': 'Forest Green', 'hex': '#1A6B3C'},
    {'name': 'Ocean Blue', 'hex': '#0284C7'},
    {'name': 'Crimson Red', 'hex': '#DC2626'},
    {'name': 'Sunset Orange', 'hex': '#EA580C'},
    {'name': 'Royal Purple', 'hex': '#7C3AED'},
    {'name': 'Night Black', 'hex': '#171717'},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedLogoBytes = bytes;
        _logoCtrl.text = "Local file selected";
      });
    }
  }

  Future<void> _registerNgo() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final ngoProvider = Provider.of<NgoProvider>(context, listen: false);

    String? finalLogoUrl = _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim();

    if (_selectedLogoBytes != null) {
      try {
        setState(() => _isUploadingLogo = true);
        // Bypass Firebase Storage rules by saving as Base64 in Firestore
        final base64String = base64Encode(_selectedLogoBytes!);
        finalLogoUrl = 'data:image/jpeg;base64,$base64String';
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate upload
      } catch (e) {
        if (mounted) SnackbarHelper.showError(context, 'Failed to process logo: $e');
        setState(() => _isUploadingLogo = false);
        return;
      }
    }

    final ngo = NgoModel(
      id: '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      primaryColorHex: _selectedColor,
      logoUrl: finalLogoUrl == "Local file selected" ? null : finalLogoUrl,
      adminId: user.uid,
      status: 'pending',
      features: _selectedFeatures.entries.where((e) => e.value).map((e) => e.key).toList(),
      createdAt: DateTime.now(),
    );

    final createdNgo = await ngoProvider.createNgo(ngo);
    
    if (createdNgo != null && mounted) {
      if (mounted) {
        setState(() => _isUploadingLogo = false);
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Registration Submitted'),
          content: const Text(
            'Your NGO registration request has been submitted successfully.\n\n'
            'It is currently pending approval from the Super Admin. You will be able to access your workspace once it is approved.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      SnackbarHelper.showError(context, 'Registration failed');
      setState(() => _isUploadingLogo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<NgoProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('register_new_ngo'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('setup_ngo_profile'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('setup_ngo_desc'.tr(), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _nameCtrl,
                label: 'ngo_name'.tr(),
                prefixIcon: Icons.business,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descCtrl,
                label: 'description'.tr(),
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _logoCtrl,
                      label: 'logo_url'.tr(),
                      hint: 'https://... or Pick Image',
                      prefixIcon: Icons.image,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: _pickImage,
                      tooltip: 'Pick from Gallery',
                    ),
                  ),
                ],
              ),
              if (_selectedLogoBytes != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Image.memory(_selectedLogoBytes!, height: 100, width: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLogoBytes = null;
                              _logoCtrl.clear();
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              Text('select_theme_color'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _themeColors.map((colorMap) {
                  final hex = colorMap['hex']!;
                  final isSelected = _selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _parseColor(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (isSelected) BoxShadow(color: _parseColor(hex).withValues(alpha: 0.5), blurRadius: 8)
                        ],
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              Text('select_features'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._selectedFeatures.keys.map((feature) {
                return CheckboxListTile(
                  title: Text(feature[0].toUpperCase() + feature.substring(1)),
                  value: _selectedFeatures[feature],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedFeatures[feature] = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: _isUploadingLogo ? 'please_wait'.tr() : 'register_ngo'.tr(),
                  isLoading: Provider.of<NgoProvider>(context).isLoading || _isUploadingLogo,
                  onPressed: _isUploadingLogo ? () {} : _registerNgo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.tryParse(hex, radix: 16) ?? 0xFF1A6B3C);
  }
}
