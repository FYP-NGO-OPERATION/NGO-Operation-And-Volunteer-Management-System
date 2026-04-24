import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _announcementsRef =>
      _db.collection('announcements');

  /// Create a new announcement
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    final docRef = _announcementsRef.doc();
    final newAnnouncement = AnnouncementModel(
      id: docRef.id,
      title: announcement.title,
      message: announcement.message,
      authorId: announcement.authorId,
      authorName: announcement.authorName,
      createdAt: DateTime.now(),
    );
    await docRef.set(newAnnouncement.toMap());
  }

  /// Stream all announcements (newest first)
  Stream<List<AnnouncementModel>> getAnnouncementsStream() {
    return _announcementsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnnouncementModel.fromMap(doc.data()))
            .toList());
  }
  
  /// Stream latest N announcements (for dashboard)
  Stream<List<AnnouncementModel>> getLatestAnnouncements(int limit) {
    return _announcementsRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnnouncementModel.fromMap(doc.data()))
            .toList());
  }

  /// Delete an announcement
  Future<void> deleteAnnouncement(String id) async {
    await _announcementsRef.doc(id).delete();
  }
}
