import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/donation_service.dart';
import '../../enums/app_enums.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Add Donation form — Volunteers or Admins can fill this.
class AddDonationScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const AddDonationScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _quantityController = TextEditingController();
  final _amountCashController = TextEditingController();
  final _amountOnlineController = TextEditingController();
  final _purposeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _transactionIdController = TextEditingController();

  DonationCategory _selectedCategory = DonationCategory.money;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  String _allocationPolicy = 'campaign_specific';
  bool _refundableIfTargetMet = false;
  DateTime _receivedDate = DateTime.now();
  
  bool _isLoading = false;
  bool _isAdmin = false;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.user;
      if (user != null) {
        setState(() {
          _isAdmin = auth.isAdmin;
          if (!_isAdmin) {
            _donorNameController.text = user.name;
            _selectedPaymentMethod = PaymentMethod.jazzCash; // Default to online for volunteers
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _donorPhoneController.dispose();
    _quantityController.dispose();
    _amountCashController.dispose();
    _amountOnlineController.dispose();
    _purposeController.dispose();
    _descriptionController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  String? _buildPurposeString() {
    final parts = <String>[];
    if (_allocationPolicy == 'campaign_specific') {
      parts.add('[Campaign-Specific]');
      if (_refundableIfTargetMet) {
        parts.add('[Refundable]');
      }
    } else {
      parts.add('[General Fund]');
    }
    final note = _purposeController.text.trim();
    if (note.isNotEmpty) {
      parts.add(note);
    }
    return parts.isEmpty ? null : parts.join(' ');
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receivedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _receivedDate = picked);
    }
  }

  Future<void> _saveDonation() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    final isMoney = _selectedCategory == DonationCategory.money;
    
    // Volunteers cannot hand in cash digitally, so cash is forced to 0 for them
    final amountCash = _isAdmin ? (double.tryParse(_amountCashController.text) ?? 0) : 0.0;
    final amountOnline = double.tryParse(_amountOnlineController.text) ?? 0;

    if (isMoney && amountCash == 0 && amountOnline == 0) {
      SnackbarHelper.showError(context, 'Please enter a valid amount.');
      return;
    }

    String? transactionId = _transactionIdController.text.trim();
    if (isMoney && !_isAdmin && transactionId.isEmpty && _selectedPaymentMethod != PaymentMethod.cash) {
      SnackbarHelper.showError(context, 'Please enter Transaction ID (TID) to verify payment.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final baseDesc = _descriptionController.text.trim();
      
      final donation = DonationModel(
        id: '',
        campaignId: widget.campaignId,
        campaignTitle: widget.campaignTitle,
        donorName: _donorNameController.text.trim(),
        donorPhone: _donorPhoneController.text.trim().isEmpty ? null : _donorPhoneController.text.trim(),
        category: _selectedCategory,
        quantity: _quantityController.text.trim(),
        amount: amountCash + amountOnline,
        amountCash: amountCash,
        amountOnline: amountOnline,
        paymentMethod: _selectedPaymentMethod,
        purpose: _buildPurposeString(),
        description: baseDesc.isEmpty ? null : baseDesc,
        transactionId: transactionId.isEmpty ? null : transactionId,
        isAnonymous: _isAnonymous,
        status: _isAdmin ? DonationStatus.approved : DonationStatus.pending,
        receivedBy: user.uid,
        receivedByName: user.name,
        receivedAt: _receivedDate,
      );

      await DonationService().addDonation(donation);

      if (!mounted) return;
      if (_isAdmin) {
        SnackbarHelper.showSuccess(context, 'Donation added successfully!');
      } else {
        SnackbarHelper.showSuccess(context, 'Donation submitted! Awaiting admin verification.');
      }
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarHelper.showError(context, 'Failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isMoney = _selectedCategory == DonationCategory.money;

    return Scaffold(
      appBar: AppBar(title: Text(_isAdmin ? 'Add Donation' : 'Donate Now', style: AppTextStyles.titleLarge())),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 520,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isAdmin && isMoney) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: AppTokens.borderRadiusMd,
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: const Text(
                          'Please transfer your funds to our official JazzCash/Easypaisa number: 0300-1234567, then enter the Transaction ID (TID) below.',
                          style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: AppTokens.borderRadiusMd,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.campaignTitle,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Donation Type', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DonationCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.category)),
                      items: DonationCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text('${cat.icon}  ${cat.label}'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    AppSpacing.vGapLg,

                    CustomTextField(
                      controller: _donorNameController,
                      label: 'Donor Name',
                      hint: 'Full name of the donor',
                      prefixIcon: Icons.person,
                      enabled: _isAdmin, // Volunteers cant change their name easily here
                      validator: (v) => v == null || v.trim().isEmpty ? 'Donor name required' : null,
                    ),
                    AppSpacing.vGapLg,

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Donate Anonymously', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Hide your name from the public list'),
                      secondary: const Icon(Icons.visibility_off, color: AppColors.textSecondary),
                      value: _isAnonymous,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isAnonymous = v),
                    ),
                    AppSpacing.vGapLg,

                    CustomTextField(
                      controller: _quantityController,
                      label: 'Quantity / Items',
                      hint: isMoney ? 'e.g., Rs. 5,000' : 'e.g., 50 shirts',
                      prefixIcon: Icons.inventory,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Quantity required' : null,
                    ),
                    AppSpacing.vGapLg,

                    if (isMoney) ...[
                      Text('Payment Method', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<PaymentMethod>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.payment)),
                        items: PaymentMethod.values
                            .where((method) => _isAdmin || method != PaymentMethod.cash)
                            .map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text('${method.icon}  ${method.label}'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                      ),
                      AppSpacing.vGapLg,

                      if (_isAdmin) ...[
                        CustomTextField(
                          controller: _amountCashController,
                          label: 'Cash Amount (Rs.)',
                          hint: '0',
                          prefixIcon: Icons.money,
                          keyboardType: TextInputType.number,
                        ),
                        AppSpacing.vGapLg,
                      ],

                      CustomTextField(
                        controller: _amountOnlineController,
                        label: _isAdmin ? 'Online Amount (Rs.)' : 'Amount Transferred (Rs.)',
                        hint: '0',
                        prefixIcon: Icons.account_balance,
                        keyboardType: TextInputType.number,
                      ),
                      AppSpacing.vGapLg,

                      if (_selectedPaymentMethod != PaymentMethod.cash) ...[
                        CustomTextField(
                          controller: _transactionIdController,
                          label: 'Transaction ID (TID) / Ref No',
                          hint: 'e.g., 0011223344',
                          prefixIcon: Icons.receipt,
                        ),
                        AppSpacing.vGapLg,
                      ],
                    ],

                    Text('Received Date', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _isAdmin ? _selectDate : null, // Volunteers cannot change date
                      child: InputDecorator(
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today)),
                        child: Text(dateFormat.format(_receivedDate)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: _isAdmin ? 'Save Donation' : 'Submit Donation',
                      isLoading: _isLoading,
                      onPressed: _saveDonation,
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
