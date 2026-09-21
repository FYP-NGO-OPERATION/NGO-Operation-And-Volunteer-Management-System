import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';

class VolunteerReportService {
  /// Generate a detailed Volunteer Impact Report PDF
  static Future<Uint8List> generateReport(
    UserModel user, {
    String timeframe = 'Monthly',
  }) async {
    final pdf = pw.Document();

    // Load HRAS logo
    final logoBytes = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Fonts
    final fontTitle = await PdfGoogleFonts.montserratBold();
    final fontNormal = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();

    final primaryColor = PdfColor.fromHex('#4CAF50'); // Green shade
    final accentColor = PdfColor.fromHex('#2196F3'); // Blue shade
    final darkColor = PdfColor.fromHex('#2C3E50'); // Dark slate

    // Dummy statistics (in a real app, these would be aggregated from Firestore)
    int totalHours = timeframe == 'Weekly'
        ? 12
        : (timeframe == 'Monthly' ? 45 : 320);
    int tasksCompleted = timeframe == 'Weekly'
        ? 3
        : (timeframe == 'Monthly' ? 14 : 98);
    int impactScore = totalHours * 10 + tasksCompleted * 5;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: fontNormal, bold: fontBold),
          buildBackground: (context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: primaryColor, width: 4),
                ),
              ),
            );
          },
        ),
        header: (context) =>
            _buildHeader(logoImage, primaryColor, darkColor, fontTitle),
        footer: (context) => _buildFooter(context, primaryColor),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildUserInfo(user, darkColor, fontBold),
          pw.SizedBox(height: 30),

          pw.Text(
            '$timeframe Impact Summary',
            style: pw.TextStyle(
              color: primaryColor,
              fontSize: 20,
              font: fontTitle,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildStatsGrid(
            totalHours,
            tasksCompleted,
            impactScore,
            user.campaignsJoined,
            primaryColor,
            accentColor,
            fontBold,
          ),

          pw.SizedBox(height: 30),

          pw.Text(
            'Activity Breakdown',
            style: pw.TextStyle(
              color: primaryColor,
              fontSize: 20,
              font: fontTitle,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildActivityTable(fontBold),

          pw.SizedBox(height: 40),
          _buildGraphPlaceholder(
            primaryColor,
          ), // Advanced charts using fl_chart usually aren't native to pdf package, so we draw custom bar charts

          pw.SizedBox(height: 40),
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Thank you for your extraordinary service and dedication to humanity!',
              style: pw.TextStyle(
                fontStyle: pw.FontStyle.italic,
                fontSize: 16,
                color: accentColor,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    pw.MemoryImage logo,
    PdfColor primary,
    PdfColor dark,
    pw.Font fontTitle,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: 80, height: 80),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'VOLUNTEER IMPACT REPORT',
              style: pw.TextStyle(
                color: primary,
                fontSize: 24,
                font: fontTitle,
              ),
            ),
            pw.Text(
              'Human Rights Awareness Society',
              style: pw.TextStyle(color: dark, fontSize: 14),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Date Generated: ${DateFormat.yMMMd().format(DateTime.now())}',
              style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildUserInfo(
    UserModel user,
    PdfColor dark,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Volunteer Name:',
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
              ),
              pw.Text(
                user.name,
                style: pw.TextStyle(color: dark, fontSize: 16, font: fontBold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Email:',
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
              ),
              pw.Text(
                user.email,
                style: pw.TextStyle(color: dark, fontSize: 12),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Member Since:',
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
              ),
              pw.Text(
                DateFormat.yMMMd().format(user.joinedAt),
                style: pw.TextStyle(color: dark, fontSize: 14, font: fontBold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Volunteer ID:',
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
              ),
              pw.Text(
                user.uid.substring(0, 8).toUpperCase(),
                style: pw.TextStyle(color: dark, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatsGrid(
    int hours,
    int tasks,
    int impact,
    int campaigns,
    PdfColor primary,
    PdfColor accent,
    pw.Font fontBold,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _statBox('Total Hours', '$hours', primary, fontBold),
        _statBox('Tasks Done', '$tasks', accent, fontBold),
        _statBox('Campaigns', '$campaigns', primary, fontBold),
        _statBox('Impact Score', '$impact', accent, fontBold),
      ],
    );
  }

  static pw.Widget _statBox(
    String title,
    String value,
    PdfColor color,
    pw.Font fontBold,
  ) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.symmetric(vertical: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(color: color, fontSize: 24, font: fontBold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildActivityTable(pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Campaign / Activity', 'Category', 'Hours Logged'],
      data: [
        ['Sep 12, 2026', 'Ramadan Ration Drive', 'Distribution', '5.0'],
        ['Sep 05, 2026', 'Flood Relief Fundraiser', 'Fundraising', '3.5'],
        ['Aug 28, 2026', 'Blood Donation Camp', 'Health', '4.0'],
        ['Aug 15, 2026', 'Old Age Home Visit', 'Social Care', '6.0'],
      ],
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF2C3E50),
      ),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
      rowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
    );
  }

  static pw.Widget _buildGraphPlaceholder(PdfColor primary) {
    // Custom Bar Chart drawn using pw.Container
    return pw.Container(
      height: 150,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Weekly Hours Trend',
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          pw.Expanded(
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _bar(40, 'W1', primary),
                _bar(70, 'W2', primary),
                _bar(50, 'W3', primary),
                _bar(90, 'W4', primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _bar(double heightPercent, String label, PdfColor color) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 30,
          height: heightPercent,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.vertical(
              top: pw.Radius.circular(4),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context, PdfColor primary) {
    return pw.Column(
      children: [
        pw.Divider(color: primary),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'HRAS NGO System',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
