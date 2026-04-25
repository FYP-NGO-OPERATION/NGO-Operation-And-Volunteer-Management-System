import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/campaign_model.dart';

class PdfReportService {
  /// Generates and previews/prints a PDF report of all campaigns
  static Future<void> generateAndPrintCampaignReport({
    required List<CampaignModel> campaigns,
    required int totalBeneficiaries,
    required int totalItems,
    required double totalDonations,
  }) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('MMM dd, yyyy');

    // Add a page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'HRAS NGO',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Campaign Analytics Report',
                    style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Generated on: ${dateFormat.format(DateTime.now())}'),
            pw.SizedBox(height: 30),

            // Summary Section
            pw.Text(
              'Overall Impact Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total Campaigns', '${campaigns.length}'),
                  _buildSummaryItem('Families Helped', '$totalBeneficiaries'),
                  _buildSummaryItem('Items Donated', '$totalItems'),
                  _buildSummaryItem('Total Funds', 'Rs.${totalDonations.toStringAsFixed(0)}'),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Campaigns Table
            pw.Text(
              'Campaigns Breakdown',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              data: <List<String>>[
                ['Title', 'Status', 'Start Date', 'Donations', 'Volunteers'],
                ...campaigns.map((c) => [
                      c.title,
                      c.status.label,
                      dateFormat.format(c.startDate),
                      'Rs.${c.totalDonationsAmount.toStringAsFixed(0)}',
                      '${c.totalVolunteers}',
                    ]),
              ],
            ),

            // Footer
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 40),
              child: pw.Center(
                child: pw.Text(
                  'End of Report. Thank you for making a difference!',
                  style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Print or Share the document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'HRAS_Campaign_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildSummaryItem(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      ],
    );
  }

  /// Generate a branded donation receipt PDF for a single donation
  static Future<void> generateDonationReceipt({
    required String donorName,
    required String donorPhone,
    required double amount,
    required String campaignTitle,
    required String paymentMethod,
    required DateTime date,
    String? receiptId,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
    final id = receiptId ?? 'HRAS-${date.millisecondsSinceEpoch.toString().substring(5)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('HRAS NGO', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('Hamesha Rahein Apke Saath', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      border: pw.Border.all(color: PdfColors.green800),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Text('DONATION RECEIPT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 20),

              // Receipt info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt #: $id', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Date: ${dateFormat.format(date)}', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 30),

              // Donor info
              pw.Text('DONOR INFORMATION', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _receiptRow('Name', donorName),
              _receiptRow('Phone', donorPhone),
              pw.SizedBox(height: 24),

              // Donation details
              pw.Text('DONATION DETAILS', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _receiptRow('Campaign', campaignTitle),
              _receiptRow('Payment Method', paymentMethod),
              pw.SizedBox(height: 12),

              // Amount highlight
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL AMOUNT', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Rs. ${amount.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                  ],
                ),
              ),

              pw.SizedBox(height: 40),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),

              // Thank you
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Thank you for your generous donation!', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text('Your contribution makes a real difference in the lives of those in need.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.SizedBox(height: 20),
                    pw.Text('HRAS NGO — Building a better future together', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'HRAS_Receipt_$id.pdf',
    );
  }

  static pw.Widget _receiptRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text('$label:', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
