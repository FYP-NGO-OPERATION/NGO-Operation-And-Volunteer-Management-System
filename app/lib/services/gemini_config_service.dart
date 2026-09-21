import 'package:cloud_firestore/cloud_firestore.dart';

class GeminiConfigService {
  /// Fetches the Gemini API key from the NGO document.
  /// Throws an exception if the key is not set or empty.
  static Future<String> getApiKey(String ngoId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('ngos')
          .doc(ngoId)
          .get();
      if (doc.exists && doc.data() != null) {
        final key = doc.data()!['geminiApiKey'] as String?;
        if (key != null && key.trim().isNotEmpty) {
          return key.trim();
        }
      }

      throw Exception(
        'Gemini API Key is not configured. Please ask the Admin to set it in AI Settings.',
      );
    } catch (e) {
      if (e.toString().contains('not configured')) {
        rethrow;
      }
      throw Exception('Failed to fetch AI configuration: $e');
    }
  }

  /// Saves a new Gemini API key to the NGO document.
  static Future<void> setApiKey(String ngoId, String newKey) async {
    await FirebaseFirestore.instance.collection('ngos').doc(ngoId).set({
      'geminiApiKey': newKey.trim(),
    }, SetOptions(merge: true));
  }
}
