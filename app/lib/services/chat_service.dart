import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream messages for a specific campaign (real-time chat)
  Stream<List<MessageModel>> streamCampaignMessages(String campaignId) {
    return _firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromMap(doc.data())).toList();
    });
  }

  // Send a new message
  Future<void> sendMessage(MessageModel message) async {
    final messageRef = _firestore
        .collection('campaigns')
        .doc(message.campaignId)
        .collection('messages')
        .doc(message.id);
        
    await messageRef.set(message.toMap());
  }

  // Generate ID
  String generateId() {
    return const Uuid().v4();
  }

  // Delete a message for everyone
  Future<void> deleteMessage(String campaignId, String messageId) async {
    final messageRef = _firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('messages')
        .doc(messageId);
        
    await messageRef.update({'isDeleted': true});
  }
}
