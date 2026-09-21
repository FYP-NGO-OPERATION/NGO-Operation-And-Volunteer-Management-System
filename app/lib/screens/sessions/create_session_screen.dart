import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/virtual_session_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/virtual_session_provider.dart';
import '../../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/snackbar_helper.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      SnackbarHelper.showError(context, 'Please select date and time');
      return;
    }

    final sessionDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final user = context.read<AuthProvider>().user;
    if (user == null || user.currentNgoId == null || user.currentNgoId!.isEmpty) {
      return;
    }

    final provider = context.read<VirtualSessionProvider>();

    // We need to set loading manually for the image upload part, then provider handles the rest
    setState(
      () {},
    ); // trigger rebuild to show loading if needed, but we can just let provider do it if we had a local loading state.
    // Let's add a local loading state to avoid modifying provider just for image upload.
    // Wait, the provider has _isLoading but no method to set it.
    // We can just rely on the button's own loading or create a local bool.

    String? uploadedImageUrl;
    if (_selectedImage != null) {
      // Temporary UI block
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      uploadedImageUrl = await CloudinaryService.uploadImage(_selectedImage!);
      if (mounted) Navigator.pop(context); // remove dialog
    }

    final session = VirtualSessionModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      meetingLink: _linkCtrl.text.trim(),
      sessionDate: sessionDate,
      createdBy: user.uid,
      createdByName: user.name,
      ngoId: user.currentNgoId!,
      createdAt: DateTime.now(),
      imageUrl: uploadedImageUrl,
      secretCode: _codeCtrl.text.trim().isNotEmpty
          ? _codeCtrl.text.trim()
          : null,
    );

    final success = await provider.addSession(session);

    if (success && mounted) {
      SnackbarHelper.showSuccess(context, 'Virtual Session Scheduled!');
      Navigator.pop(context);
    } else if (mounted) {
      SnackbarHelper.showError(
        context,
        provider.error ?? 'Failed to schedule session',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VirtualSessionProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Virtual Session')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleCtrl,
                label: 'Session Title',
                prefixIcon: Icons.title,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl,
                label: 'Description / Agenda',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _linkCtrl,
                label: 'Meeting Link (Zoom / Google Meet)',
                prefixIcon: Icons.link,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!val.startsWith('http')) return 'Enter a valid URL';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _codeCtrl,
                label: 'Verification Code (Optional)',
                prefixIcon: Icons.lock,
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(
                  _selectedDate != null && _selectedTime != null
                      ? DateFormat('MMM dd, yyyy - hh:mm a').format(
                          DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          ),
                        )
                      : 'Select Date & Time',
                  style: TextStyle(
                    color: _selectedDate != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.grey,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _pickDateTime,
                  child: const Text('PICK'),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Cover Image (Optional)',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_selectedImage != null)
                TextButton.icon(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove Image',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'SCHEDULE SESSION',
                onPressed: _submit,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
