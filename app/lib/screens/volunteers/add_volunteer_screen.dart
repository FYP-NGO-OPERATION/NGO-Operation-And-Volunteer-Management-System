import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/volunteer_service.dart';
import '../../utils/snackbar_helper.dart';

/// Admin-only screen to manually add a volunteer to a campaign.
/// Used for recording past participants of completed campaigns.
class AddVolunteerScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const AddVolunteerScreen({
    Key? key,
    required this.campaignId,
    required this.campaignTitle,
  }) : super(key: key);

  @override
  State<AddVolunteerScreen> createState() => _AddVolunteerScreenState();
}

class _AddVolunteerScreenState extends State<AddVolunteerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedStatus = 'attended';
  bool _isSaving = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'attended', 'label': 'Attended', 'icon': '✅'},
    {'value': 'registered', 'label': 'Registered', 'icon': '📝'},
    {'value': 'confirmed', 'label': 'Confirmed', 'icon': '✔️'},
    {'value': 'absent', 'label': 'Absent', 'icon': '❌'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final adminUser = context.read<AuthProvider>().user!;
      final volunteerService = VolunteerService();

      await volunteerService.addVolunteerManually(
        campaignId: widget.campaignId,
        campaignTitle: widget.campaignTitle,
        volunteerName: _nameCtrl.text.trim(),
        volunteerEmail: _emailCtrl.text.trim().isEmpty
            ? '${_nameCtrl.text.trim().replaceAll(' ', '').toLowerCase()}@manual.hras'
            : _emailCtrl.text.trim(),
        volunteerPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        statusStr: _selectedStatus,
        addedByAdminId: adminUser.uid,
      );

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '${_nameCtrl.text.trim()} added as volunteer!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Failed: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Volunteer'),
            Text(
              widget.campaignTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Manually add a volunteer who participated in this campaign. '
                        'Email is optional for past volunteers.',
                        style: TextStyle(fontSize: 13, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),

              // Email (optional)
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'Leave blank if not available',
                ),
              ),
              const SizedBox(height: 14),

              // Phone (optional)
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone (optional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Status
              Text(
                'Volunteer Status',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _statusOptions.map((opt) {
                  final isSelected = _selectedStatus == opt['value'];
                  return Material(
                    color: Colors.transparent,
                    child: ChoiceChip(
                      label: Text('${opt['icon']} ${opt['label']}'),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedStatus = opt['value']!),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.person_add),
                  label: Text(_isSaving ? 'Saving...' : 'Add Volunteer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
