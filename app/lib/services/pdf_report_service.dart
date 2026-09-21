import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign_model.dart';
import '../models/user_model.dart';
import 'campaign_service.dart';

/// PDF Report Generation Service (FYP-02 Feature Module).
///
/// VIVA PREP EXPLANATION:
/// Q: How do you generate reports?
/// A: Sir, we use the Flutter 'pdf' and 'printing' packages. The service fetches
///    all campaign data from Firestore, calculates totals (like total donations),
///    and then draws a programmatic A4-sized PDF document. It uses a tabular layout
///    which the admin can easily print or share via WhatsApp to stakeholders.
class PdfReportService {
  PdfReportService._();

  static Future<void> generateAndDownloadReport({required String ngoId}) async {
    final pdf = pw.Document();

    // 1. Fetch campaigns for specific NGO
    final campaigns = await CampaignService().fetchAllCampaigns(ngoId);

    // 2. Fetch Top Volunteers for Leaderboard Report
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'volunteer')
        .where('currentNgoId', isEqualTo: ngoId)
        .limit(20)
        .get();

    final topVolunteers =
        usersSnapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList()
          ..sort((a, b) => b.campaignsJoined.compareTo(a.campaignsJoined));
    final topFive = topVolunteers.take(5).toList();

    // ignore: unused_local_variable
    int totalDonationsCount = 0;
    double totalDonationsAmount = 0.0;
    int totalVolunteers = 0;

    for (var c in campaigns) {
      totalDonationsCount += c.totalDonationsCount;
      totalDonationsAmount += c.totalDonationsAmount;
      totalVolunteers += c.totalVolunteers;
    }

    final dateStr = DateFormat('MMMM yyyy').format(DateTime.now());

    // Load logo image bytes
    pw.MemoryImage? logoImage;
    try {
      final data = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      // Fallback if logo not found
    }

    // 3. Build PDF Layout
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(logoImage),
            pw.SizedBox(height: 20),
            _buildSummaryCards(
              campaigns.length,
              totalVolunteers,
              totalDonationsAmount,
            ),
            pw.SizedBox(height: 30),

            // Top Volunteers Section (Added for Viva Request)
            pw.Text(
              'Volunteer Performance Leaderboard (Top 5)',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),
            _buildTopVolunteersTable(topFive),
            pw.SizedBox(height: 30),

            // Campaigns Section
            pw.Text(
              'Active Campaigns Breakdown',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            _buildCampaignTable(campaigns),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );

    // 4. Save to Temp Directory and Open using open_file
    try {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/HRAS_Report_${dateStr.replaceAll(' ', '_')}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint('Error saving/opening PDF: $e');
      rethrow;
    }
  }

  static pw.Widget _buildHeader(pw.MemoryImage? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            if (logoImage != null)
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  image: pw.DecorationImage(
                    image: logoImage,
                    fit: pw.BoxFit.cover,
                  ),
                ),
              )
            else
              // Fallback Programmatic Logo
              pw.Container(
                width: 60,
                height: 60,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue800,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    'H',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
            pw.SizedBox(width: 16),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'HRAS NGO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'Operations & Volunteer Management',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Overall NGO Operations Report',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Scope: All-Time Records',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCards(
    int totalCampaigns,
    int totalVolunteers,
    double totalDonations,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _summaryBox('Total Campaigns', totalCampaigns.toString()),
        _summaryBox('Active Volunteers', totalVolunteers.toString()),
        _summaryBox(
          'Total Donations',
          'Rs. ${NumberFormat('#,##0').format(totalDonations)}',
        ),
      ],
    );
  }

  static pw.Widget _summaryBox(String title, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCampaignTable(List<CampaignModel> campaigns) {
    final tableHeaders = [
      'Campaign Name',
      'Type',
      'Volunteers',
      'Donations (Rs)',
    ];

    final tableData = campaigns.map((c) {
      return [
        c.title,
        c.type.name.toUpperCase(),
        c.totalVolunteers.toString(),
        NumberFormat('#,##0').format(c.totalDonationsAmount),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: tableHeaders,
      data: tableData,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTopVolunteersTable(List<UserModel> topVolunteers) {
    final tableHeaders = ['Rank', 'Volunteer Name', 'Campaigns Joined'];

    int rank = 1;
    final tableData = topVolunteers.map((v) {
      return ['#${rank++}', v.name, v.campaignsJoined.toString()];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: tableHeaders,
      data: tableData,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.amber800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
      },
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '--- END OF REPORT ---',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'System Generated Report - No signature required.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'For inquiries, contact admin@hras.org',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        // Programmatic Stamp
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.red800, width: 2),
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Transform.rotate(
              angle: -0.5,
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'VERIFIED',
                    style: pw.TextStyle(
                      color: PdfColors.red800,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'HRAS ADMIN',
                    style: const pw.TextStyle(
                      color: PdfColors.red800,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> generateDonationReceipt({
    required String donorName,
    required String donorPhone,
    required double amount,
    required String campaignTitle,
    required String paymentMethod,
    required DateTime date,
    required String receiptId,
  }) async {
    debugPrint('Stub for generateDonationReceipt');
  }

  static Future<void> generateAndPrintCampaignReport({
    required List<CampaignModel> campaigns,
    required int totalBeneficiaries,
    required int totalItems,
    required double totalDonations,
  }) async {
    final pdf = pw.Document();
    final campaign = campaigns.first;
    final dateStr = DateFormat('MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Text(
              'CAMPAIGN IMPACT REPORT',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Campaign: ${campaign.title}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Organization: ${campaign.ngoName}'),
            pw.Text(
              'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _summaryBox(
                  'Total Donations',
                  'Rs. ${NumberFormat('#,##0').format(totalDonations)}',
                ),
                _summaryBox(
                  'Active Volunteers',
                  campaign.totalVolunteers.toString(),
                ),
                _summaryBox(
                  'Goal Status',
                  campaign.isCompleted ? 'Completed' : 'Active',
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Description',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(campaign.description),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/CampaignReport_${dateStr.replaceAll(' ', '_')}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint('Error saving/opening PDF: $e');
      rethrow;
    }
  }
}
