import 'package:cloud_firestore/cloud_firestore.dart';

/// Beneficiary model — tracks individuals/families who received help.
class BeneficiaryModel {
  final String id;
  final String campaignId;
  final String name;
  final String? phone;
  final String address;
  final int familySize;
  final String itemsReceived;
  final DateTime receivedAt;
  final String? notes;
  final String addedBy;

  BeneficiaryModel({
    required this.id,
    required this.campaignId,
    required this.name,
    this.phone,
    required this.address,
    required this.familySize,
    required this.itemsReceived,
    required this.receivedAt,
    this.notes,
    required this.addedBy,
  });

  factory BeneficiaryModel.fromMap(Map<String, dynamic> map) {
    return BeneficiaryModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      address: map['address'] ?? '',
      familySize: map['familySize'] ?? 1,
      itemsReceived: map['itemsReceived'] ?? '',
      receivedAt: (map['receivedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      addedBy: map['addedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'name': name,
      'phone': phone,
      'address': address,
      'familySize': familySize,
      'itemsReceived': itemsReceived,
      'receivedAt': Timestamp.fromDate(receivedAt),
      'notes': notes,
      'addedBy': addedBy,
    };
  }
}
