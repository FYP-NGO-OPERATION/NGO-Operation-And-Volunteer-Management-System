import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/campaign_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../enums/app_enums.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Create or Edit campaign form (Admin only).
class CreateCampaignScreen extends StatefulWidget {
  final CampaignModel? campaign; // null = create, non-null = edit

  const CreateCampaignScreen({super.key, this.campaign});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _targetGoalController = TextEditingController();
  final _itemsNeededController = TextEditingController();
  final _volunteerLimitController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  CampaignType _selectedType = CampaignType.custom;
  CampaignStatus _selectedStatus = CampaignStatus.upcoming;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool get _isEditing => widget.campaign != null;

  File? _highlightVideo;
  List<File> _galleryImages = [];
  File? _projectRecordPdf;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickVideo() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'videos',
      extensions: <String>['mp4', 'mov', 'avi'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      setState(() => _highlightVideo = File(file.path));
    }
  }

  Future<void> _pickGalleryImages() async {
    final pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _galleryImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _pickPdf() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'pdfs',
      extensions: <String>['pdf'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      setState(() => _projectRecordPdf = File(file.path));
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.campaign!;
      _titleController.text = c.title;
      _descriptionController.text = c.description;
      _locationController.text = c.location;
      _latitudeController.text = c.latitude?.toString() ?? '';
      _longitudeController.text = c.longitude?.toString() ?? '';
      _targetGoalController.text = c.targetGoal;
      _itemsNeededController.text = c.itemsNeeded ?? '';
      _volunteerLimitController.text =
          c.volunteerLimit != null ? c.volunteerLimit.toString() : '';
      _selectedType = c.type;
      _selectedStatus = c.status;
      _startDate = c.startDate;
      _endDate = c.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _targetGoalController.dispose();
    _itemsNeededController.dispose();
    _volunteerLimitController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate.add(const Duration(days: 7))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
    final user = authProvider.user!;

    final volunteerLimit = _volunteerLimitController.text.isNotEmpty
        ? int.tryParse(_volunteerLimitController.text)
        : null;

    bool success;

    if (!_isEditing) {
      if (_endDate != null && _endDate!.isBefore(DateTime.now())) {
        _selectedStatus = CampaignStatus.completed;
      } else if (_endDate == null && _startDate.isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
        // If no end date but started more than 7 days ago, assume completed for historical entry
        _selectedStatus = CampaignStatus.completed;
      } else if (_startDate.isBefore(DateTime.now())) {
        _selectedStatus = CampaignStatus.active;
      }
    }

    if (_isEditing) {
      final updated = widget.campaign!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
        targetGoal: _targetGoalController.text.trim(),
        itemsNeeded: _itemsNeededController.text.trim().isEmpty
            ? null
            : _itemsNeededController.text.trim(),
        volunteerLimit: volunteerLimit,
      );
      success = await campaignProvider.updateCampaign(updated);
    } else {
      final newCampaign = CampaignModel(
        id: '',
        ngoId: user.currentNgoId ?? 'HRAS_DEFAULT_ID',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
        targetGoal: _targetGoalController.text.trim(),
        itemsNeeded: _itemsNeededController.text.trim().isEmpty
            ? null
            : _itemsNeededController.text.trim(),
        volunteerLimit: volunteerLimit,
        createdBy: user.uid,
        createdByName: user.name,
        ngoName: user.ngoName,
        createdAt: DateTime.now(),
      );
      success = await campaignProvider.createCampaign(
        newCampaign,
        videoFile: _highlightVideo,
        galleryFiles: _galleryImages,
        documentFile: _projectRecordPdf,
      );
    }

    if (!mounted) return;

    if (success) {
      SnackbarHelper.showSuccess(
        context,
        _isEditing ? 'Campaign updated!' : 'Campaign created!',
      );
      Navigator.pop(context);
    } else {
      SnackbarHelper.showError(
        context,
        campaignProvider.error ?? 'Something went wrong.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Campaign' : 'Create Campaign'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 520,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Campaign Type ───
                    Text('Campaign Type', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CampaignType>(
                      // ignore: deprecated_member_use
                      value: _selectedType,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: CampaignType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text('${type.icon}  ${type.label}'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 16),

                    // ─── Title ───
                    CustomTextField(
                      controller: _titleController,
                      label: 'Campaign Title',
                      hint: 'e.g., Ramadan Dastarkhan 2026',
                      prefixIcon: Icons.title,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ─── Description ───
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Describe the campaign purpose and goals...',
                      prefixIcon: Icons.description,
                      maxLines: 4,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ─── Location ───
                    CustomTextField(
                      controller: _locationController,
                      label: 'Location Name',
                      hint: 'e.g., Lahore, Gulberg',
                      prefixIcon: Icons.location_on,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Location is required' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _latitudeController,
                            label: 'Lat (Optional)',
                            hint: 'e.g. 24.8607',
                            prefixIcon: Icons.map,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _longitudeController,
                            label: 'Lng (Optional)',
                            hint: 'e.g. 67.0011',
                            prefixIcon: Icons.map,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Target Goal ───
                    CustomTextField(
                      controller: _targetGoalController,
                      label: 'Target Goal',
                      hint: 'e.g., Distribute 500 ration packs',
                      prefixIcon: Icons.flag,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Target is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ─── Items Needed (optional) ───
                    CustomTextField(
                      controller: _itemsNeededController,
                      label: 'Items Needed (Optional)',
                      hint: 'e.g., 500 packs, 50 volunteers, 100K PKR',
                      prefixIcon: Icons.list_alt,
                    ),
                    const SizedBox(height: 16),

                    // ─── Volunteer Limit (optional) ───
                    CustomTextField(
                      controller: _volunteerLimitController,
                      label: 'Volunteer Limit (Optional)',
                      hint: 'Max volunteers (leave empty for no limit)',
                      prefixIcon: Icons.people,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // ─── Start Date ───
                    Text('Start Date', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(dateFormat.format(_startDate)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── End Date (optional) ───
                    Text('End Date (Optional)', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: _endDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => setState(() => _endDate = null),
                                )
                              : null,
                        ),
                        child: Text(
                          _endDate != null ? dateFormat.format(_endDate!) : 'Select end date',
                          style: _endDate == null
                              ? TextStyle(color: Theme.of(context).hintColor)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ─── Status (edit only) ───
                    if (_isEditing) ...[
                      Text('Status', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<CampaignStatus>(
                        // ignore: deprecated_member_use
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.flag_circle),
                        ),
                        items: CampaignStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text('${status.icon} ${status.label}'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v!),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ─── Multimedia Upload Section (Create Only) ───
                    if (!_isEditing) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Multimedia (Optional)', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      
                      // Highlight Video
                      ListTile(
                        leading: const Icon(Icons.video_library),
                        title: const Text('Highlight Video (MP4)'),
                        subtitle: Text(_highlightVideo != null ? _highlightVideo!.path.split('\\').last.split('/').last : 'No video selected'),
                        trailing: OutlinedButton(
                          onPressed: _pickVideo,
                          child: const Text('Pick Video'),
                        ),
                      ),
                      
                      // Project Record PDF
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text('Project Record (PDF)'),
                        subtitle: Text(_projectRecordPdf != null ? _projectRecordPdf!.path.split('\\').last.split('/').last : 'No PDF selected'),
                        trailing: OutlinedButton(
                          onPressed: _pickPdf,
                          child: const Text('Pick PDF'),
                        ),
                      ),

                      // Gallery Images
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Gallery Images'),
                        subtitle: Text('${_galleryImages.length} images selected'),
                        trailing: OutlinedButton(
                          onPressed: _pickGalleryImages,
                          child: const Text('Pick Images'),
                        ),
                      ),
                      if (_galleryImages.isNotEmpty)
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _galleryImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(_galleryImages[index], width: 70, height: 70, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () => setState(() => _galleryImages.removeAt(index)),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close, size: 12, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],

                    const SizedBox(height: 12),

                    // ─── Save Button ───
                    Consumer<CampaignProvider>(
                      builder: (context, provider, _) {
                        return CustomButton(
                          text: _isEditing ? 'Update Campaign' : 'Create Campaign',
                          isLoading: provider.isLoading,
                          onPressed: _saveCampaign,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
