import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/report_service.dart';
import '../../services/pdf_generator_service.dart';
import '../../utils/snackbar_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.darkTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generateAndPreviewPdf() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final campaigns = await _reportService.getCampaignsForReport(
        user.currentNgoId ?? '',
        _startDate,
        _endDate,
      );
      final donations = await _reportService.getDonationsForReport(
        _startDate,
        _endDate,
      );
      final expenses = await _reportService.getExpensesForReport(
        _startDate,
        _endDate,
      );

      final pdfBytes = await PdfGeneratorService.generateReport(
        title: 'Monthly Operations Report',
        ngoName: user.ngoName ?? 'NGO Volunteer App',
        startDate: _startDate,
        endDate: _endDate,
        campaigns: campaigns,
        donations: donations,
        expenses: expenses,
      );

      if (!mounted) return;

      // Navigate to a preview screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Report Preview')),
            body: PdfPreview(
              build: (format) => pdfBytes,
              canChangeOrientation: false,
              canChangePageFormat: false,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Failed to generate PDF: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Generate PDF Reports',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a date range to generate a comprehensive report of campaigns, donations, and expenses.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.date_range,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _selectDateRange(context),
                      child: const Text('Change Date Range'),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateAndPreviewPdf,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(
                  _isLoading ? 'Generating...' : 'Generate PDF Report',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
