
class InventoryItemModel {
  final String id;
  final String ngoId;
  final String name;
  final int quantity;
  final String unit;
  final DateTime lastUpdated;
  final String? description;

  InventoryItemModel({
    required this.id,
    required this.ngoId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.lastUpdated,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ngoId': ngoId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'lastUpdated': lastUpdated.toIso8601String(),
      'description': description,
    };
  }

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      id: map['id'] ?? '',
      ngoId: map['ngoId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      unit: map['unit'] ?? '',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
      description: map['description'],
    );
  }

  InventoryItemModel copyWith({
    String? id,
    String? ngoId,
    String? name,
    int? quantity,
    String? unit,
    DateTime? lastUpdated,
    String? description,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      ngoId: ngoId ?? this.ngoId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      description: description ?? this.description,
    );
  }
}
