import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String campaignId;
  final String title;
  final String description;
  final String assignedToId;
  final String assignedToName;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.description,
    required this.assignedToId,
    required this.assignedToName,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'title': title,
      'description': description,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedToId: map['assignedToId'] ?? '',
      assignedToName: map['assignedToName'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? assignedToId,
    String? assignedToName,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      campaignId: campaignId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
