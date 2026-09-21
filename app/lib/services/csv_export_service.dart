import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/campaign_model.dart';
import '../utils/snackbar_helper.dart';

class CsvExportService {
  static Future<void> exportCampaignsToCsv(
    BuildContext context,
    List<CampaignModel> campaigns,
  ) async {
    try {
      List<List<dynamic>> rows = [];

      // Headers
      rows.add([
        'ID',
        'Title',
        'Type',
        'Status',
        'Location',
        'Start Date',
        'End Date',
        'Target Goal',
        'Total Volunteers',
        'Total Donations (Rs)',
        'Total Expenses (Rs)',
        'Created By',
      ]);

      // Data
      for (var campaign in campaigns) {
        rows.add([
          campaign.id,
          campaign.title,
          campaign.type.label,
          campaign.status.label,
          campaign.location,
          campaign.startDate.toIso8601String(),
          campaign.endDate?.toIso8601String() ?? 'N/A',
          campaign.targetGoal,
          campaign.totalVolunteers,
          campaign.totalDonationsAmount,
          campaign.totalExpenses,
          campaign.createdByName,
        ]);
      }

      final StringBuffer sb = StringBuffer();
      for (var row in rows) {
        sb.writeln(
          row.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','),
        );
      }
      String csvData = sb.toString();

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/campaigns_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvData);

      if (context.mounted) {
        SnackbarHelper.showSuccess(context, 'Data exported successfully!');
        Share.shareXFiles([XFile(path)], text: 'Campaigns Export CSV');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, 'Failed to export data: $e');
      }
    }
  }
}
