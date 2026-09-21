import 'package:cloud_firestore/cloud_firestore.dart';

class ShopService {
  final FirebaseFirestore _db;

  ShopService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<void> checkout(
    String userId,
    String userName,
    List<dynamic> cartItems,
    double total,
  ) async {
    final batch = _db.batch();

    // Save order
    final orderRef = _db.collection('orders').doc();
    batch.set(orderRef, {
      'userId': userId,
      'userName': userName,
      'items': cartItems.map((e) => e.toMap()).toList(),
      'total': total,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'paid',
    });

    // Update stock
    for (var item in cartItems) {
      final docRef = _db.collection('products').doc(item.id);
      batch.update(docRef, {'stock': FieldValue.increment(-1)});
    }

    // Admin notification
    final notifRef = _db.collection('admin_notifications').doc();
    batch.set(notifRef, {
      'title': 'New E-Store Order!',
      'body': '\ bought \ items (\total).',
      'type': 'order',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<QuerySnapshot> getProductsStream() {
    return _db.collection('products').snapshots();
  }
}
