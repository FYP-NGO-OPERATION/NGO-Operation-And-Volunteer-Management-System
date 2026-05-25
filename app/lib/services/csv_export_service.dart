import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/campaign_model.dart';
import '../utils/snackbar_helper.dart';

class CsvExportService {
  static Future<void> exportCampaignsToCsv(BuildContext context, List<CampaignModel> campaigns) async {
    try {
      List<List<dynamic>> rows = [];
      
      // Headers
      rows.add([
        'Campaign ID',
        'Title',
        'Type',
        'Status',
        'Location',
        'Start Date',
        'End Date',
        'Target Goal',
        'Total Donations (Rs)',
        'Volunteers Registered',
        'Created At'
      ]);

      // Data Rows
      for (var campaign in campaigns) {
        rows.add([
          campaign.id,
          campaign.title,
          campaign.type.name,
          campaign.status.name,
          campaign.location,
          DateFormat('yyyy-MM-dd').format(campaign.startDate),
          campaign.endDate != null ? DateFormat('yyyy-MM-dd').format(campaign.endDate!) : 'N/A',
          campaign.targetGoal,
          campaign.totalDonationsAmount,
          campaign.registeredVolunteersCount,
          DateFormat('yyyy-MM-dd HH:mm').format(campaign.createdAt),
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final Uint8List bytes = utf8.encoder.convert(csvData);

      final XFile file = XFile.fromData(
        bytes,
        mimeType: 'text/csv',
        name: 'campaigns_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      );

      await Share.shareXFiles(
        [file],
        subject: 'Campaigns Export Data',
        text: 'Here is the exported CSV data of all campaigns.',
      );

    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Failed to export data: $e');
      }
    }
  }
}
