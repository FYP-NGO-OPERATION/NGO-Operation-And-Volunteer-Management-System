import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  CampaignType _selectedType = CampaignType.custom;
  CampaignStatus _selectedStatus = CampaignStatus.upcoming;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool get _isEditing => widget.campaign != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.campaign!;
      _titleController.text = c.title;
      _descriptionController.text = c.description;
      _locationController.text = c.location;
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

    if (_isEditing) {
      final updated = widget.campaign!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text.trim(),
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
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        location: _locationController.text.trim(),
        targetGoal: _targetGoalController.text.trim(),
        itemsNeeded: _itemsNeededController.text.trim().isEmpty
            ? null
            : _itemsNeededController.text.trim(),
        volunteerLimit: volunteerLimit,
        createdBy: user.uid,
        createdByName: user.name,
        createdAt: DateTime.now(),
      );
      success = await campaignProvider.createCampaign(newCampaign);
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
                      label: 'Location',
                      hint: 'e.g., Lahore, Gulberg',
                      prefixIcon: Icons.location_on,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Location is required' : null,
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
