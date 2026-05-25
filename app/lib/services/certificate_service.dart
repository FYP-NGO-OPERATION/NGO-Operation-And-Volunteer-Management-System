import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class CertificateService {
  /// Generates a beautiful PDF Certificate of Appreciation and opens the print/share dialog.
  static Future<void> generateAndDownloadCertificate({
    required String volunteerName,
    required int campaignsAttended,
    String? ngoName = "HRAS Platform",
  }) async {
    final pdf = pw.Document();

    // Determine badge text
    String badgeText = "BRONZE BADGE";
    PdfColor badgeColor = PdfColor.fromHex('#CD7F32'); // Bronze
    if (campaignsAttended >= 5) {
      badgeText = "GOLD BADGE";
      badgeColor = PdfColor.fromHex('#FFD700'); // Gold
    } else if (campaignsAttended >= 3) {
      badgeText = "SILVER BADGE";
      badgeColor = PdfColor.fromHex('#C0C0C0'); // Silver
    }

    final dateStr = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: badgeColor, width: 10),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'CERTIFICATE OF APPRECIATION',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1E3A8A'),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'This certificate is proudly presented to',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  volunteerName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 40,
                    fontWeight: pw.FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'in recognition of their outstanding dedication and service.',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Successfully completed $campaignsAttended campaign(s) and earned the $badgeText.',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(width: 150, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 5),
                        pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: badgeColor,
                          ),
                          child: pw.Text(
                            badgeText.split(' ')[0],
                            style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(width: 150, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 5),
                        pw.Text('Authorized by: $ngoName', style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${volunteerName}_Certificate',
    );
  }
}
