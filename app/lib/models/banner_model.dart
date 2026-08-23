import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String targetType; // 'campaign', 'session', 'external', 'none'
  final String? targetId; // ID of the campaign or session (if applicable)
  final String? targetUrl; // URL if it's an external link
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.targetType = 'none',
    this.targetId,
    this.targetUrl,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'targetType': targetType,
      'targetId': targetId,
      'targetUrl': targetUrl,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map, String docId) {
    return BannerModel(
      id: docId,
      imageUrl: map['imageUrl'] ?? '',
      targetType: map['targetType'] ?? 'none',
      targetId: map['targetId'],
      targetUrl: map['targetUrl'],
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder']?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
