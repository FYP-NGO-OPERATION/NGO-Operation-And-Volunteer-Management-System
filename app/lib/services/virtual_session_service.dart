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

  Future<void> deleteSession(String sessionId) async {
    await _db.collection(collectionPath).doc(sessionId).delete();
  }
}
