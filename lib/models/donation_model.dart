import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

/// Donation model — tracks all donations for campaigns.
/// Enhanced with NGO leader requirements: payment method, online vs cash,
/// purpose, and who received the donation.
class DonationModel {
  final String id;
  final String campaignId;
  final String campaignTitle;

  // ─── Donor Info ───
  final String donorName;
  final String? donorPhone;
  final String? donorCnic;

  // ─── Donation Details ───
  final DonationCategory category;
  final String quantity;          // "50 shirts", "20 ration packs"
  final double amount;            // Total monetary value (Rs.)
  final double amountCash;        // Cash / by hand amount
  final double amountOnline;      // Online transfer amount
  final PaymentMethod paymentMethod;
  final String? purpose;          // Leader: "Purpose of donation"
  final String? description;

  // ─── Received By ───
  final String receivedBy;        // User ID who collected it
  final String receivedByName;    // Denormalized name
  final DateTime receivedAt;      // When donation was received

  // ─── Meta ───
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.donorName,
    this.donorPhone,
    this.donorCnic,
    required this.category,
    required this.quantity,
    this.amount = 0,
    this.amountCash = 0,
    this.amountOnline = 0,
    this.paymentMethod = PaymentMethod.cash,
    this.purpose,
    this.description,
    required this.receivedBy,
    required this.receivedByName,
    required this.receivedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Total amount (cash + online)
  double get totalAmount => amountCash + amountOnline;

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      campaignTitle: map['campaignTitle'] ?? '',
      donorName: map['donorName'] ?? '',
      donorPhone: map['donorPhone'],
      donorCnic: map['donorCnic'],
      category: DonationCategory.fromString(map['category'] ?? 'other'),
      quantity: map['quantity'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      amountCash: (map['amountCash'] ?? 0).toDouble(),
      amountOnline: (map['amountOnline'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.fromString(map['paymentMethod'] ?? 'cash'),
      purpose: map['purpose'],
      description: map['description'],
      receivedBy: map['receivedBy'] ?? '',
      receivedByName: map['receivedByName'] ?? '',
      receivedAt: (map['receivedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'donorCnic': donorCnic,
      'category': category.name,
      'quantity': quantity,
      'amount': amount,
      'amountCash': amountCash,
      'amountOnline': amountOnline,
      'paymentMethod': paymentMethod.name,
      'purpose': purpose,
      'description': description,
      'receivedBy': receivedBy,
      'receivedByName': receivedByName,
      'receivedAt': Timestamp.fromDate(receivedAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Helpers
  bool get isMoney => category == DonationCategory.money;
  bool get isInKind => category != DonationCategory.money;

  @override
  String toString() => 'Donation($donorName, ${category.label}, $quantity)';
}
