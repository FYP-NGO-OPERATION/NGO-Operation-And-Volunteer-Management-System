import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

/// Expense model — tracks all purchases and costs for a campaign.
/// From NGO leader: "We buy things for the event — item, quantity, price, total spent, saved."
class ExpenseModel {
  final String id;
  final String campaignId;
  final String itemName;
  final ExpenseCategory category;
  final int quantity;
  final String? unit;
  final double unitPrice;
  final double totalAmount;
  final String? vendor;
  final String? billImageUrl;
  final String? notes;
  final String addedBy;
  final String addedByName;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.campaignId,
    required this.itemName,
    required this.category,
    required this.quantity,
    this.unit,
    required this.unitPrice,
    required this.totalAmount,
    this.vendor,
    this.billImageUrl,
    this.notes,
    required this.addedBy,
    required this.addedByName,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      itemName: map['itemName'] ?? '',
      category: ExpenseCategory.fromString(map['category'] ?? 'other'),
      quantity: map['quantity'] ?? 1,
      unit: map['unit'],
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      vendor: map['vendor'],
      billImageUrl: map['billImageUrl'],
      notes: map['notes'],
      addedBy: map['addedBy'] ?? '',
      addedByName: map['addedByName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'itemName': itemName,
      'category': category.name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'vendor': vendor,
      'billImageUrl': billImageUrl,
      'notes': notes,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() => 'ExpenseModel(item: $itemName, qty: $quantity × Rs.$unitPrice = Rs.$totalAmount)';
}
