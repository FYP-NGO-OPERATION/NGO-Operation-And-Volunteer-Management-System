import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String campaignId;
  final String title;
  final String description;
  final List<String> assignedToIds;
  final List<String> assignedToNames;
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.description,
    required this.assignedToIds,
    required this.assignedToNames,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'title': title,
      'description': description,
      'assignedToIds': assignedToIds,
      'assignedToNames': assignedToNames,
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
      assignedToIds: map['assignedToIds'] != null
          ? List<String>.from(map['assignedToIds'])
          : (map['assignedToId'] != null ? [map['assignedToId']] : []),
      assignedToNames: map['assignedToNames'] != null
          ? List<String>.from(map['assignedToNames'])
          : (map['assignedToName'] != null ? [map['assignedToName']] : []),
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    List<String>? assignedToIds,
    List<String>? assignedToNames,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      campaignId: campaignId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToIds: assignedToIds ?? this.assignedToIds,
      assignedToNames: assignedToNames ?? this.assignedToNames,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
