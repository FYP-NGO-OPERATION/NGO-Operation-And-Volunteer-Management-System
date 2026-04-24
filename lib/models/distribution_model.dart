import 'package:cloud_firestore/cloud_firestore.dart';

/// Distribution model — tracks what was distributed during a campaign.
class DistributionModel {
  final String id;
  final String campaignId;
  final String itemType;
  final int quantity;
  final String unit;
  final int distributedTo;
  final String distributedBy;
  final DateTime distributedAt;
  final String location;
  final String? notes;

  DistributionModel({
    required this.id,
    required this.campaignId,
    required this.itemType,
    required this.quantity,
    required this.unit,
    required this.distributedTo,
    required this.distributedBy,
    required this.distributedAt,
    required this.location,
    this.notes,
  });

  factory DistributionModel.fromMap(Map<String, dynamic> map) {
    return DistributionModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      itemType: map['itemType'] ?? 'other',
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? 'pieces',
      distributedTo: map['distributedTo'] ?? 0,
      distributedBy: map['distributedBy'] ?? '',
      distributedAt: (map['distributedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] ?? '',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'itemType': itemType,
      'quantity': quantity,
      'unit': unit,
      'distributedTo': distributedTo,
      'distributedBy': distributedBy,
      'distributedAt': Timestamp.fromDate(distributedAt),
      'location': location,
      'notes': notes,
    };
  }
}
