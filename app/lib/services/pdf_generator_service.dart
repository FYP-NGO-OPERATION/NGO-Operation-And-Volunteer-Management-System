import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/campaign_model.dart';
import '../models/donation_model.dart';
import '../models/expense_model.dart';
import '../enums/app_enums.dart';

class PdfGeneratorService {
  /// Generate Monthly/Periodic Report PDF for a specific campaign or overall.
  static Future<Uint8List> generateReport({
    required String title,
    required String ngoName,
    required DateTime startDate,
    required DateTime endDate,
    List<CampaignModel> campaigns = const [],
    List<DonationModel> donations = const [],
    List<ExpenseModel> expenses = const [],
  }) async {
    final pdf = pw.Document();

    // Attempt to load a font (useful for standard text)
    // For Urdu, we'd need a specific font, but we will stick to English for the PDF report.
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final dateFormat = DateFormat('MMM dd, yyyy');

    // Calculate aggregates
    final totalDonations = donations
        .where((d) => d.status == DonationStatus.approved)
        .fold(0.0, (s, d) => s + d.totalAmount);
    final totalExpenses = expenses.fold(0.0, (s, e) => s + e.totalAmount);
    final balance = totalDonations - totalExpenses;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      ngoName,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Official NGO Report',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Date Generated: ${dateFormat.format(DateTime.now())}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                    pw.Text(
                      'Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 2, color: PdfColors.blue200),
            pw.SizedBox(height: 20),

            // Title
            pw.Center(
              child: pw.Text(
                title,
                style: pw.TextStyle(font: fontBold, fontSize: 20),
              ),
            ),
            pw.SizedBox(height: 24),

            // Summary Cards
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryBox(
                  'Total Donations',
                  'Rs. ${totalDonations.toStringAsFixed(0)}',
                  PdfColors.green700,
                  font,
                  fontBold,
                ),
                _buildSummaryBox(
                  'Total Expenses',
                  'Rs. ${totalExpenses.toStringAsFixed(0)}',
                  PdfColors.red700,
                  font,
                  fontBold,
                ),
                _buildSummaryBox(
                  'Net Balance',
                  'Rs. ${balance.toStringAsFixed(0)}',
                  balance >= 0 ? PdfColors.blue700 : PdfColors.red700,
                  font,
                  fontBold,
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            if (campaigns.isNotEmpty) ...[
              pw.Text(
                'Campaign Highlights',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  font: fontBold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue600,
                ),
                cellStyle: pw.TextStyle(font: font),
                cellAlignment: pw.Alignment.centerLeft,
                data: [
                  ['Campaign Name', 'Status', 'Volunteers', 'Beneficiaries'],
                  ...campaigns.map(
                    (c) => [
                      c.title,
                      c.status.name.toUpperCase(),
                      c.totalVolunteers.toString(),
                      c.beneficiaryCount.toString(),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            if (donations.isNotEmpty) ...[
              pw.Text(
                'Recent Donations',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.green800,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  font: fontBold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.green600,
                ),
                cellStyle: pw.TextStyle(font: font),
                cellAlignment: pw.Alignment.centerLeft,
                data: [
                  ['Date', 'Donor', 'Category', 'Amount/Qty'],
                  ...donations
                      .take(20)
                      .map(
                        (d) => [
                          dateFormat.format(d.createdAt),
                          d.isAnonymous ? 'Anonymous' : d.donorName,
                          d.category.name,
                          d.isMoney
                              ? 'Rs. ${d.totalAmount.toStringAsFixed(0)}'
                              : d.quantity,
                        ],
                      ),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            if (expenses.isNotEmpty) ...[
              pw.Text(
                'Recent Expenses',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.red800,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(
                  font: fontBold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.red600,
                ),
                cellStyle: pw.TextStyle(font: font),
                cellAlignment: pw.Alignment.centerLeft,
                data: [
                  ['Date', 'Item Name', 'Category', 'Total Cost'],
                  ...expenses
                      .take(20)
                      .map(
                        (e) => [
                          dateFormat.format(e.createdAt),
                          e.itemName,
                          e.category.name,
                          'Rs. ${e.totalAmount.toStringAsFixed(0)}',
                        ],
                      ),
                ],
              ),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryBox(
    String title,
    String value,
    PdfColor color,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      width: 130,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(font: fontBold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
