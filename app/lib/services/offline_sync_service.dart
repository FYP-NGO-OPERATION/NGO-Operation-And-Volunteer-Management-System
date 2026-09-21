import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const String _offlineQueueKey = 'offline_sync_queue';
const String syncTaskName = 'syncOfflineDataTask';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  /// Adds a Firestore mutation to the offline queue
  Future<void> queueMutation(String collection, String docId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> queue = prefs.getStringList(_offlineQueueKey) ?? [];

    final payload = {
      'collection': collection,
      'docId': docId,
      'data': data,
      'queuedAt': DateTime.now().toIso8601String(),
    };

    queue.add(jsonEncode(payload));
    await prefs.setStringList(_offlineQueueKey, queue);

    // Schedule background task to flush queue when network is available
    Workmanager().registerOneOffTask(
      "syncOfflineData_${DateTime.now().millisecondsSinceEpoch}",
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected
      ),
    );
    
    debugPrint('Queued offline mutation for $collection/$docId');
  }

  /// Flushes the queue by writing all stored mutations to Firestore
  static Future<bool> flushQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> queue = prefs.getStringList(_offlineQueueKey) ?? [];

      if (queue.isEmpty) {
        return true;
      }

      final batch = FirebaseFirestore.instance.batch();

      for (final itemStr in queue) {
        final Map<String, dynamic> item = jsonDecode(itemStr);
        final docRef = FirebaseFirestore.instance
            .collection(item['collection'])
            .doc(item['docId']);
            
        // Assuming we are setting data with merge to avoid overwriting existing data if modified elsewhere
        batch.set(docRef, item['data'], SetOptions(merge: true));
      }

      await batch.commit();

      // Clear queue after successful commit
      await prefs.remove(_offlineQueueKey);
      debugPrint('Successfully flushed offline sync queue (${queue.length} items)');
      return true;
    } catch (e) {
      debugPrint('Failed to flush offline sync queue: $e');
      return false;
    }
  }
}
