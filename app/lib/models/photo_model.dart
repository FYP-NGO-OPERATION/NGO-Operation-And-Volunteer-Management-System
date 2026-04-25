import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String id;
  final String campaignId;
  final String imageUrl;
  final String caption;
  final String uploadedBy;
  final String uploaderName;
  final DateTime createdAt;

  PhotoModel({
    required this.id,
    required this.campaignId,
    required this.imageUrl,
    this.caption = '',
    required this.uploadedBy,
    required this.uploaderName,
    required this.createdAt,
  });

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploaderName: map['uploaderName'] ?? 'Admin',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'imageUrl': imageUrl,
      'caption': caption,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
