import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';
import 'package:uuid/uuid.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream feedbacks for a specific campaign
  Stream<List<FeedbackModel>> streamCampaignFeedbacks(String campaignId) {
    return _firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => FeedbackModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Check if user already submitted feedback
  Future<bool> hasUserSubmittedFeedback(
    String campaignId,
    String volunteerId,
  ) async {
    final query = await _firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('feedbacks')
        .where('volunteerId', isEqualTo: volunteerId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // Submit feedback
  Future<void> submitFeedback(FeedbackModel feedback) async {
    final feedbackRef = _firestore
        .collection('campaigns')
        .doc(feedback.campaignId)
        .collection('feedbacks')
        .doc(feedback.id);

    await feedbackRef.set(feedback.toMap());
  }

  // Generate ID
  String generateId() {
    return const Uuid().v4();
  }
}
