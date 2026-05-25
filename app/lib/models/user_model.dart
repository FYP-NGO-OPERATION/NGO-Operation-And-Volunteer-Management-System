import 'package:cloud_firestore/cloud_firestore.dart';

/// User data model — maps to Firestore `users` collection.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin' or 'volunteer'
  final String? profileImageUrl;
  final String? bio;
  final String? address;
  final String? ngoName; // FYP-03 Multi-NGO feature (legacy)
  final String? currentNgoId; // Phase 7: Multi-Tenant SaaS
  final List<String> skills;
  final bool emailVerified;
  final DateTime joinedAt;
  final bool isActive;
  final int campaignsJoined;
  final DateTime? lastActiveAt;
  final List<String> badges;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'volunteer',
    this.profileImageUrl,
    this.bio,
    this.address,
    this.ngoName,
    this.currentNgoId,
    this.skills = const [],
    this.emailVerified = false,
    required this.joinedAt,
    this.isActive = true,
    this.campaignsJoined = 0,
    this.lastActiveAt,
    this.badges = const [],
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
      bio: map['bio'],
      address: map['address'],
      ngoName: map['ngoName'],
      currentNgoId: map['currentNgoId'],
      skills: List<String>.from(map['skills'] ?? []),
      emailVerified: map['emailVerified'] ?? false,
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      campaignsJoined: map['campaignsJoined'] ?? 0,
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
      badges: List<String>.from(map['badges'] ?? []),
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
      'bio': bio,
      'address': address,
      'ngoName': ngoName,
      'currentNgoId': currentNgoId,
      'skills': skills,
      'emailVerified': emailVerified,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
      'campaignsJoined': campaignsJoined,
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'badges': badges,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? phone,
    String? role,
    String? profileImageUrl,
    String? bio,
    String? address,
    String? ngoName,
    String? currentNgoId,
    List<String>? skills,
    bool? emailVerified,
    bool? isActive,
    int? campaignsJoined,
    DateTime? lastActiveAt,
    List<String>? badges,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      ngoName: ngoName ?? this.ngoName,
      currentNgoId: currentNgoId ?? this.currentNgoId,
      skills: skills ?? this.skills,
      emailVerified: emailVerified ?? this.emailVerified,
      joinedAt: joinedAt,
      isActive: isActive ?? this.isActive,
      campaignsJoined: campaignsJoined ?? this.campaignsJoined,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      badges: badges ?? this.badges,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is volunteer
  bool get isVolunteer => role == 'volunteer';

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: $role)';
}
