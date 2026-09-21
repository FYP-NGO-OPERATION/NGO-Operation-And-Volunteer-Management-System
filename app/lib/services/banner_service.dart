import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';

class BannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generateId() => _db.collection('banners').doc().id;

  Future<void> createBanner(BannerModel banner) async {
    await _db.collection('banners').doc(banner.id).set(banner.toMap());
  }

  Future<void> updateBanner(BannerModel banner) async {
    await _db.collection('banners').doc(banner.id).update(banner.toMap());
  }

  Future<void> deleteBanner(String id) async {
    await _db.collection('banners').doc(id).delete();
  }

  Future<void> toggleBannerStatus(String id, bool isActive) async {
    await _db.collection('banners').doc(id).update({'isActive': isActive});
  }

  Future<void> updateSortOrder(String id, int sortOrder) async {
    await _db.collection('banners').doc(id).update({'sortOrder': sortOrder});
  }

  Stream<List<BannerModel>> getActiveBanners() {
    return _db
        .collection('banners')
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BannerModel.fromMap(doc.data(), doc.id))
              .where((banner) => banner.isActive)
              .toList(),
        );
  }

  Stream<List<BannerModel>> getAllBanners() {
    return _db
        .collection('banners')
        .orderBy('sortOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BannerModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
