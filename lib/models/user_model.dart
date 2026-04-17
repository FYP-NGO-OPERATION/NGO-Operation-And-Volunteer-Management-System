import 'package:cloud_firestore/cloud_firestore.dart';

/// User data model — maps to Firestore `users` collection.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin' or 'volunteer'
  final String? profileImageUrl;
  final String? address;
  final List<String> skills;
  final bool emailVerified;
  final DateTime joinedAt;
  final bool isActive;
  final int campaignsJoined;
  final DateTime? lastActiveAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'volunteer',
    this.profileImageUrl,
    this.address,
    this.skills = const [],
    this.emailVerified = false,
    required this.joinedAt,
    this.isActive = true,
    this.campaignsJoined = 0,
    this.lastActiveAt,
  });

  /// Create UserModel from Firestore document snapshot
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'volunteer',
      profileImageUrl: map['profileImageUrl'],
      address: map['address'],
      skills: List<String>.from(map['skills'] ?? []),
      emailVerified: map['emailVerified'] ?? false,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      campaignsJoined: map['campaignsJoined'] ?? 0,
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'skills': skills,
      'emailVerified': emailVerified,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
      'campaignsJoined': campaignsJoined,
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? phone,
    String? role,
    String? profileImageUrl,
    String? address,
    List<String>? skills,
    bool? emailVerified,
    bool? isActive,
    int? campaignsJoined,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      skills: skills ?? this.skills,
      emailVerified: emailVerified ?? this.emailVerified,
      joinedAt: joinedAt,
      isActive: isActive ?? this.isActive,
      campaignsJoined: campaignsJoined ?? this.campaignsJoined,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is volunteer
  bool get isVolunteer => role == 'volunteer';

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: $role)';
}
