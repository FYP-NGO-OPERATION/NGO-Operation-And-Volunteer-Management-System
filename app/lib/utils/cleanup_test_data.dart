import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility to clean up test/fake data from Firestore.
/// Call `CleanupTestData.run()` once from admin dashboard, then remove the call.
class CleanupTestData {
  static Future<Map<String, int>> run() async {
    final firestore = FirebaseFirestore.instance;
    int campaignsDeleted = 0;
    int sessionsDeleted = 0;

    // Delete test campaigns (titles starting with "Test")
    final campaigns = await firestore.collection('campaigns').get();
    for (final doc in campaigns.docs) {
      final title = (doc.data()['title'] ?? '') as String;
      if (title.toLowerCase().startsWith('test ')) {
        await doc.reference.delete();
        campaignsDeleted++;
      }
    }

    // Delete test virtual sessions (titles starting with "Test")
    final sessions = await firestore.collection('virtual_sessions').get();
    for (final doc in sessions.docs) {
      final title = (doc.data()['title'] ?? '') as String;
      if (title.toLowerCase().startsWith('test ')) {
        await doc.reference.delete();
        sessionsDeleted++;
      }
    }

    return {
      'campaignsDeleted': campaignsDeleted,
      'sessionsDeleted': sessionsDeleted,
    };
  }
}
