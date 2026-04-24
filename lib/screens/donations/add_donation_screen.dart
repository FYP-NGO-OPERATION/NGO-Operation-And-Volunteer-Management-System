import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/donation_service.dart';
import '../../enums/app_enums.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'payment_processing_screen.dart';

/// Add Donation form — Admin fills donor info, amount, payment method.
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

  DonationCategory _selectedCategory = DonationCategory.money;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _receivedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _donorNameController.dispose();
    _donorPhoneController.dispose();
    _quantityController.dispose();
    _amountCashController.dispose();
    _amountOnlineController.dispose();
    _purposeController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    final amountCash = double.tryParse(_amountCashController.text) ?? 0;
    final amountOnline = double.tryParse(_amountOnlineController.text) ?? 0;

    if (isMoney && amountCash == 0 && amountOnline == 0) {
      SnackbarHelper.showError(context, 'Please enter a valid amount (Cash or Online).');
      return;
    }

    String? transactionId;
    if (isMoney && _selectedPaymentMethod != PaymentMethod.cash) {
      // Simulate Payment Gateway
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentProcessingScreen(
            paymentMethod: _selectedPaymentMethod,
            amount: amountCash + amountOnline,
            donorName: _donorNameController.text.trim(),
          ),
        ),
      );

      if (!mounted) return;
      if (result != null && result is String) {
        transactionId = result;
      } else {
        SnackbarHelper.showError(context, 'Payment was cancelled or failed.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final baseDesc = _descriptionController.text.trim();
      final finalDesc = transactionId != null 
          ? '[Txn ID: $transactionId] ${baseDesc.isNotEmpty ? baseDesc : 'Online Payment'}'
          : baseDesc.isEmpty ? null : baseDesc;

      final donation = DonationModel(
        id: '',
        campaignId: widget.campaignId,
        campaignTitle: widget.campaignTitle,
        donorName: _donorNameController.text.trim(),
        donorPhone: _donorPhoneController.text.trim().isEmpty
            ? null
            : _donorPhoneController.text.trim(),
        category: _selectedCategory,
        quantity: _quantityController.text.trim(),
        amount: amountCash + amountOnline,
        amountCash: amountCash,
        amountOnline: amountOnline,
        paymentMethod: _selectedPaymentMethod,
        purpose: _purposeController.text.trim().isEmpty
            ? null
            : _purposeController.text.trim(),
        description: finalDesc,
        receivedBy: user.uid,
        receivedByName: user.name,
        receivedAt: _receivedDate,
      );

      await DonationService().addDonation(donation);

      if (!mounted) return;
      SnackbarHelper.showSuccess(context, 'Donation added successfully!');
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
      appBar: AppBar(
        title: const Text('Add Donation'),
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
                    // Campaign name badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
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

                    // ─── Donation Category ───
                    Text('Donation Type', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DonationCategory>(
                      // ignore: deprecated_member_use
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: DonationCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text('${cat.icon}  ${cat.label}'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),

                    // ─── Donor Name ───
                    CustomTextField(
                      controller: _donorNameController,
                      label: 'Donor Name',
                      hint: 'Full name of the donor',
                      prefixIcon: Icons.person,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Donor name required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ─── Donor Phone (optional) ───
                    CustomTextField(
                      controller: _donorPhoneController,
                      label: 'Donor Phone (Optional)',
                      hint: '03XX-XXXXXXX',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // ─── Quantity ───
                    CustomTextField(
                      controller: _quantityController,
                      label: 'Quantity / Items',
                      hint: isMoney
                          ? 'e.g., Rs. 5,000'
                          : 'e.g., 50 shirts, 20 ration packs',
                      prefixIcon: Icons.inventory,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Quantity required' : null,
                    ),
                    const SizedBox(height: 16),

                    // ─── Money Fields (only for money category) ───
                    if (isMoney) ...[
                      // Payment Method
                      Text('Payment Method', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<PaymentMethod>(
                        // ignore: deprecated_member_use
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: PaymentMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text('${method.icon}  ${method.label}'),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPaymentMethod = v!),
                      ),
                      const SizedBox(height: 16),

                      // Cash Amount
                      CustomTextField(
                        controller: _amountCashController,
                        label: 'Cash Amount (Rs.)',
                        hint: '0',
                        prefixIcon: Icons.money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Online Amount
                      CustomTextField(
                        controller: _amountOnlineController,
                        label: 'Online Amount (Rs.)',
                        hint: '0',
                        prefixIcon: Icons.account_balance,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ─── Purpose (optional) ───
                    CustomTextField(
                      controller: _purposeController,
                      label: 'Purpose (Optional)',
                      hint: 'e.g., For ration distribution',
                      prefixIcon: Icons.flag,
                    ),
                    const SizedBox(height: 16),

                    // ─── Description (optional) ───
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Notes (Optional)',
                      hint: 'Any extra details...',
                      prefixIcon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // ─── Received Date ───
                    Text('Received Date', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(dateFormat.format(_receivedDate)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Save Button ───
                    CustomButton(
                      text: 'Save Donation',
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
