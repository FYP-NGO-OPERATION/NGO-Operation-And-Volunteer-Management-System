import 'package:cloud_firestore/cloud_firestore.dart';

class VirtualSessionModel {
  final String id;
  final String title;
  final String description;
  final String meetingLink;
  final DateTime sessionDate;
  final String createdBy;
  final String createdByName;
  final String ngoId;
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, String> rsvpUsers;
  final Map<String, String> attendedUsers;
  final String? secretCode;

  VirtualSessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.meetingLink,
    required this.sessionDate,
    required this.createdBy,
    required this.createdByName,
    required this.ngoId,
    required this.createdAt,
    this.imageUrl,
    this.rsvpUsers = const {},
    this.attendedUsers = const {},
    this.secretCode,
  });

  factory VirtualSessionModel.fromMap(Map<String, dynamic> map) {
    return VirtualSessionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      meetingLink: map['meetingLink'] ?? '',
      sessionDate: (map['sessionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? 'Admin',
      ngoId: map['ngoId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      rsvpUsers: Map<String, String>.from(map['rsvpUsers'] ?? {}),
      attendedUsers: Map<String, String>.from(map['attendedUsers'] ?? {}),
      secretCode: map['secretCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'meetingLink': meetingLink,
      'sessionDate': Timestamp.fromDate(sessionDate),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'ngoId': ngoId,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'rsvpUsers': rsvpUsers,
      'attendedUsers': attendedUsers,
      if (secretCode != null) 'secretCode': secretCode,
    };
  }

  bool get isUpcoming => sessionDate.isAfter(DateTime.now());
}
