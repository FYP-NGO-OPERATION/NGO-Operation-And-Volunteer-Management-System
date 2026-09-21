import 'package:cloud_firestore/cloud_firestore.dart';

class NgoModel {
  final String id;
  final String name;
  final String description;
  final String primaryColorHex;
  final String? secondaryColorHex;
  final String? logoUrl;
  final String? bannerUrl;
  final String adminId;
  final String status; // 'pending', 'approved', 'rejected'
  final List<String> features;
  final DateTime createdAt;

  // Customization texts
  final String? welcomeText;
  final String? missionStatement;
  final String? websiteUrl;

  // Settings
  final String? geminiApiKey;

  NgoModel({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColorHex,
    this.secondaryColorHex,
    this.logoUrl,
    this.bannerUrl,
    required this.adminId,
    required this.status,
    required this.features,
    required this.createdAt,
    this.welcomeText,
    this.missionStatement,
    this.websiteUrl,
    this.geminiApiKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'adminId': adminId,
      'status': status,
      'features': features,
      'createdAt': Timestamp.fromDate(createdAt),
      'welcomeText': welcomeText,
      'missionStatement': missionStatement,
      'websiteUrl': websiteUrl,
      'geminiApiKey': geminiApiKey,
    };
  }

  factory NgoModel.fromMap(Map<String, dynamic> map) {
    return NgoModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      primaryColorHex: map['primaryColorHex'] ?? '#1A6B3C',
      secondaryColorHex: map['secondaryColorHex'],
      logoUrl: map['logoUrl'],
      bannerUrl: map['bannerUrl'],
      adminId: map['adminId'] ?? '',
      status: map['status'] ?? 'pending',
      features: List<String>.from(
        map['features'] ??
            ['campaigns', 'donations', 'volunteers', 'leaderboard'],
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      welcomeText: map['welcomeText'],
      missionStatement: map['missionStatement'],
      websiteUrl: map['websiteUrl'],
      geminiApiKey: map['geminiApiKey'],
    );
  }
}
