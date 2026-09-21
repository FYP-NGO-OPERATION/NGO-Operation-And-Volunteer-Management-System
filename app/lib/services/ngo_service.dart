import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ngo_model.dart';

class NgoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collection References ───
  CollectionReference<Map<String, dynamic>> get _ngos => _db.collection('ngos');

  /// Create a new NGO
  Future<NgoModel> createNgo(NgoModel ngo) async {
    final docRef = _ngos.doc();
    final newNgo = NgoModel(
      id: docRef.id,
      name: ngo.name,
      description: ngo.description,
      primaryColorHex: ngo.primaryColorHex,
      secondaryColorHex: ngo.secondaryColorHex,
      logoUrl: ngo.logoUrl,
      bannerUrl: ngo.bannerUrl,
      adminId: ngo.adminId,
      status: ngo.status,
      features: ngo.features,
      createdAt: DateTime.now(),
      welcomeText: ngo.welcomeText,
      missionStatement: ngo.missionStatement,
      websiteUrl: ngo.websiteUrl,
    );
    await docRef.set(newNgo.toMap());
    return newNgo;
  }

  /// Get NGO by ID
  Future<NgoModel?> getNgo(String id) async {
    final doc = await _ngos.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return NgoModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Get all NGOs
  Future<List<NgoModel>> getAllNgos() async {
    final snapshot = await _ngos.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => NgoModel.fromMap(doc.data())).toList();
  }

  /// Stream all NGOs
  Stream<List<NgoModel>> streamAllNgos() {
    return _ngos
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => NgoModel.fromMap(doc.data())).toList(),
        );
  }

  /// Update NGO
  Future<void> updateNgo(String id, Map<String, dynamic> data) async {
    await _ngos.doc(id).update(data);
  }
}
