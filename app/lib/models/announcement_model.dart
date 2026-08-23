import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String authorId;
  final String authorName;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.authorId,
    required this.authorName,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Admin',
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'authorId': authorId,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
