import 'dart:io';
import 'package:flutter/material.dart';
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
import 'components/campaign_basic_form.dart';
import 'components/campaign_logistics_form.dart';
import 'components/campaign_media_picker.dart';

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
  final _requiredSkillsController = TextEditingController();
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
      _requiredSkillsController.text = c.requiredSkills.join(', ');
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
    _requiredSkillsController.dispose();
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

    final reqSkills = _requiredSkillsController.text.trim().isEmpty 
        ? <String>[] 
        : _requiredSkillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

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
        requiredSkills: reqSkills,
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
        requiredSkills: reqSkills,
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
                    CampaignBasicForm(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      requiredSkillsController: _requiredSkillsController,
                      selectedType: _selectedType,
                      onTypeChanged: (v) => setState(() => _selectedType = v!),
                    ),
                    const SizedBox(height: 16),
                    CampaignLogisticsForm(
                      locationController: _locationController,
                      latitudeController: _latitudeController,
                      longitudeController: _longitudeController,
                      targetGoalController: _targetGoalController,
                      itemsNeededController: _itemsNeededController,
                      volunteerLimitController: _volunteerLimitController,
                      startDate: _startDate,
                      endDate: _endDate,
                      onSelectDate: _selectDate,
                      isEditing: _isEditing,
                      selectedStatus: _selectedStatus,
                      onStatusChanged: (v) => setState(() => _selectedStatus = v!),
                      onClearEndDate: () => setState(() => _endDate = null),
                    ),
                    if (!_isEditing) 
                      CampaignMediaPicker(
                        highlightVideo: _highlightVideo,
                        projectRecordPdf: _projectRecordPdf,
                        galleryImages: _galleryImages,
                        onPickVideo: _pickVideo,
                        onPickPdf: _pickPdf,
                        onPickGalleryImages: _pickGalleryImages,
                        onRemoveGalleryImage: (index) => setState(() => _galleryImages.removeAt(index)),
                      ),
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
