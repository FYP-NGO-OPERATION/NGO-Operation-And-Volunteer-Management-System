import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _skillsController = TextEditingController();
  
  String? _selectedBloodGroup;
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  
  bool _isLoading = false;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Added image compression to save storage
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (mounted) {
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _bioController.text = user.bio ?? '';
      _addressController.text = user.address ?? '';
      _skillsController.text = user.skills.join(', ');
      _selectedBloodGroup = user.bloodGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final skillsList = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
      'address': _addressController.text.trim(),
      'skills': skillsList,
    };

    final authProvider = context.read<AuthProvider>();

    // Upload image if selected
    if (_selectedImageBytes != null) {
      final success = await authProvider.uploadProfilePicture(_selectedImageBytes!);
      if (!success) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Failed to upload profile picture.')),
        );
        return; // Stop execution
      }
    }

    await authProvider.updateProfile(
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      bio: data['bio'] as String?,
      address: data['address'] as String?,
      skills: data['skills'] as List<String>?,
      bloodGroup: _selectedBloodGroup,
    );
    
    // Refresh user state
    await authProvider.checkAuthState();

    if (!mounted) return;
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile', style: AppTextStyles.titleLarge())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primarySurface,
                      backgroundImage: _selectedImageBytes != null
                          ? MemoryImage(_selectedImageBytes!) as ImageProvider
                          : (context.read<AuthProvider>().user?.profileImageUrl != null
                              ? CachedNetworkImageProvider(context.read<AuthProvider>().user!.profileImageUrl!)
                              : null),
                      child: _selectedImageBytes == null && context.read<AuthProvider>().user?.profileImageUrl == null
                          ? Text(
                              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 40, color: AppColors.primary),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vGapXl,
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              AppSpacing.vGapLg,
              // Read-only email display
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email, color: AppColors.textSecondary, size: 22),
                  enabled: false,
                ),
                child: Text(
                  Provider.of<AuthProvider>(context, listen: false).user?.email ?? '',
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
              ),
              AppSpacing.vGapLg,
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              AppSpacing.vGapLg,
              CustomTextField(
                controller: _bioController,
                label: 'Bio / About',
                prefixIcon: Icons.info_outline,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                hint: 'Tell us about yourself...',
              ),
              AppSpacing.vGapLg,
              CustomTextField(
                controller: _addressController,
                label: 'Address (City, Area)',
                prefixIcon: Icons.location_on,
              ),
              AppSpacing.vGapLg,
              CustomTextField(
                controller: _skillsController,
                label: 'Skills (comma separated)',
                hint: 'e.g., Photography, Driving, Medical',
                prefixIcon: Icons.star,
              ),
              AppSpacing.vGapLg,
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: Icon(Icons.bloodtype, color: Colors.red),
                  border: OutlineInputBorder(),
                ),
                items: _bloodGroups.map((bg) {
                  return DropdownMenuItem(value: bg, child: Text(bg));
                }).toList(),
                onChanged: (val) => setState(() => _selectedBloodGroup = val),
              ),
              AppSpacing.vGapXxl,
              CustomButton(
                text: 'SAVE CHANGES',
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
