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
}
