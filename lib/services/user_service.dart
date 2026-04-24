import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../config/app_constants.dart';

/// Handles all Firestore operations for the `users` collection.
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Reference to users collection
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection(AppConstants.usersCollection);

  /// Create new user document in Firestore after registration
  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap());
  }

  /// Get user by ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!);
  }

  /// Stream user data (real-time updates)
  Stream<UserModel?> userStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  /// Update user profile
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['lastActiveAt'] = FieldValue.serverTimestamp();
    await _usersRef.doc(uid).update(data);
  }

  /// Update profile image URL
  Future<void> updateProfileImage(String uid, String imageUrl) async {
    await _usersRef.doc(uid).update({
      'profileImageUrl': imageUrl,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersRef.orderBy('joinedAt', descending: true).get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  /// Stream all users (admin only)
  Stream<List<UserModel>> getAllUsersStream() {
    return _usersRef.orderBy('joinedAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  /// Search users by name
  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _usersRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  /// Change user role (admin only)
  Future<void> changeUserRole(String uid, String newRole) async {
    await _usersRef.doc(uid).update({
      'role': newRole,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Activate/Deactivate user (admin only)
  Future<void> setUserActive(String uid, bool isActive) async {
    await _usersRef.doc(uid).update({
      'isActive': isActive,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increment campaigns joined counter
  Future<void> incrementCampaignsJoined(String uid) async {
    await _usersRef.doc(uid).update({
      'campaignsJoined': FieldValue.increment(1),
    });
  }

  /// Decrement campaigns joined counter
  Future<void> decrementCampaignsJoined(String uid) async {
    await _usersRef.doc(uid).update({
      'campaignsJoined': FieldValue.increment(-1),
    });
  }

  /// Delete user document
  Future<void> deleteUser(String uid) async {
    await _usersRef.doc(uid).delete();
  }
}
