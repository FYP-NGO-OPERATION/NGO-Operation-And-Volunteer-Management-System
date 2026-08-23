import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingEventModel {
  final String id;
  final String donationId;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  TrackingEventModel({
    required this.id,
    required this.donationId,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = true,
  });

  factory TrackingEventModel.fromMap(Map<String, dynamic> map, String docId) {
    return TrackingEventModel(
      id: docId,
      donationId: map['donationId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: map['isCompleted'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'isCompleted': isCompleted,
    };
  }
}
