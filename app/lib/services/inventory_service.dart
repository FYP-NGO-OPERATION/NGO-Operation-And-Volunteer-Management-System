import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item_model.dart';
import 'package:uuid/uuid.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Create or Update
  Future<void> saveItem(InventoryItemModel item) async {
    final docRef = _firestore
        .collection('inventory')
        .doc(item.id.isEmpty ? _uuid.v4() : item.id);

    final updatedItem = item.copyWith(
      id: docRef.id,
      lastUpdated: DateTime.now(),
    );

    await docRef.set(updatedItem.toMap(), SetOptions(merge: true));
  }

  // Read all for an NGO
  Stream<List<InventoryItemModel>> getInventoryStream(String ngoId) {
    return _firestore
        .collection('inventory')
        .where('ngoId', isEqualTo: ngoId)
        .where('is_deleted', isNotEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => InventoryItemModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Delete
  Future<void> deleteItem(String itemId) async {
    await _firestore.collection('inventory').doc(itemId).update({
      'is_deleted': true,
      'deleted_at': FieldValue.serverTimestamp(),
    });
  }
}
