import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/virtual_session_model.dart';
import 'package:uuid/uuid.dart';

class VirtualSessionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'virtual_sessions';

  Future<void> createSession(VirtualSessionModel session) async {
    await _db.collection(collectionPath).doc(session.id).set(session.toMap());
  }

  Stream<List<VirtualSessionModel>> streamSessionsByNgo(String ngoId) {
    return _db
        .collection(collectionPath)
        .where('ngoId', isEqualTo: ngoId)
        .orderBy('sessionDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VirtualSessionModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<VirtualSessionModel?> getSessionById(String sessionId) async {
    final doc = await _db.collection(collectionPath).doc(sessionId).get();
    if (!doc.exists) return null;
    return VirtualSessionModel.fromMap(doc.data()!);
  }

  Future<void> deleteSession(String sessionId) async {
    await _db.collection(collectionPath).doc(sessionId).delete();
  }

  Future<void> toggleRSVP(String sessionId, String userId, String userName) async {
    final docRef = _db.collection(collectionPath).doc(sessionId);
    
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Session does not exist!");
      
      final Map<String, dynamic> data = snapshot.data()!;
      final rsvpUsers = Map<String, dynamic>.from(data['rsvpUsers'] ?? {});
      
      if (rsvpUsers.containsKey(userId)) {
        rsvpUsers.remove(userId);
      } else {
        rsvpUsers[userId] = userName;
      }
      
      transaction.update(docRef, {'rsvpUsers': rsvpUsers});
    });
  }

  Future<void> markAttendance(String sessionId, String userId, String userName) async {
    final docRef = _db.collection(collectionPath).doc(sessionId);
    await docRef.set({
      'attendedUsers': {userId: userName}
    }, SetOptions(merge: true));
  }
}
