import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/photo_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class GalleryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _campaignPhotos =>
      _db.collection('campaign_photos');

  /// Compresses an image before upload to save bandwidth
  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${_uuid.v4()}_compressed.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // 70% quality is usually good enough for mobile viewing
      minWidth: 1080,
      minHeight: 1080,
    );

    return result != null ? File(result.path) : null;
  }

  /// Uploads a photo to Firebase Storage and saves the URL to Firestore
  Future<void> uploadPhoto({
    required String campaignId,
    required File imageFile,
    required String caption,
    required String uploadedBy,
    required String uploaderName,
  }) async {
    // 1. Compress Image
    File fileToUpload = imageFile;
    final compressedFile = await _compressImage(imageFile);
    if (compressedFile != null) {
      fileToUpload = compressedFile;
    }

    // 2. Upload to Firebase Storage
    final fileName = '${_uuid.v4()}.jpg';
    final storageRef = _storage.ref().child('campaign_photos/$campaignId/$fileName');
    
    final uploadTask = storageRef.putFile(fileToUpload);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // 3. Save to Firestore
    final docRef = _campaignPhotos.doc();
    final newPhoto = PhotoModel(
      id: docRef.id,
      campaignId: campaignId,
      imageUrl: downloadUrl,
      caption: caption,
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      createdAt: DateTime.now(),
    );

    await docRef.set(newPhoto.toMap());
  }

  /// Stream photos for a specific campaign
  Stream<List<PhotoModel>> getCampaignPhotos(String campaignId) {
    return _campaignPhotos
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PhotoModel.fromMap(doc.data())).toList());
  }

  /// Delete a photo from both Storage and Firestore
  Future<void> deletePhoto(PhotoModel photo) async {
    // 1. Delete from Firestore
    await _campaignPhotos.doc(photo.id).delete();

    // 2. Delete from Storage
    try {
      final storageRef = _storage.refFromURL(photo.imageUrl);
      await storageRef.delete();
    } catch (e) {
      // Ignore if storage file doesn't exist or is invalid
    }
  }
}
