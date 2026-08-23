import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String campaignId;
  final String senderId;
  final String senderName;
  final String text;
  final bool isAdmin;
  final DateTime timestamp;
  final bool isDeleted;
  final List<String> mentionedUserIds;
  final String? imageUrl;

  MessageModel({
    required this.id,
    required this.campaignId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.isAdmin = false,
    required this.timestamp,
    this.isDeleted = false,
    this.mentionedUserIds = const [],
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'isAdmin': isAdmin,
      'timestamp': Timestamp.fromDate(timestamp),
      'isDeleted': isDeleted,
      'mentionedUserIds': mentionedUserIds,
      'imageUrl': imageUrl,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown',
      text: map['text'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: map['isDeleted'] ?? false,
      mentionedUserIds: map['mentionedUserIds'] != null ? List<String>.from(map['mentionedUserIds']) : [],
      imageUrl: map['imageUrl'],
    );
  }
}
