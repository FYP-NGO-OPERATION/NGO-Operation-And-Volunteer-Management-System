import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String campaignId;
  final String volunteerId;
  final String volunteerName;
  final double rating; // 1.0 to 5.0
  final String comment;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.campaignId,
    required this.volunteerId,
    required this.volunteerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      volunteerId: map['volunteerId'] ?? '',
      volunteerName: map['volunteerName'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
