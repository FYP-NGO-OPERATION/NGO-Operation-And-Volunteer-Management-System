import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

/// Campaign data model — maps to Firestore `campaigns` collection.
class CampaignModel {
  final String id;
  final String title;
  final String description;
  final CampaignType type;
  final CampaignStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? coverImageUrl;
  final String? posterImageUrl;
  final String? videoUrl;
  final String? documentUrl;
  final List<String> galleryUrls;
  final String targetGoal;
  final String? achievedGoal;
  final String? itemsNeeded;
  final List<String> requiredSkills;
  final int totalVolunteers;
  final int? volunteerLimit;
  final double totalDonationsAmount;
  final int totalDonationsCount;
  final int beneficiaryCount;
  final int distributionCount;
  final double totalExpenses;
  final int progressPercent;
  final String createdBy;
  final String createdByName;
  final String? ngoName; // FYP-03 Multi-NGO feature (legacy)
  final String ngoId; // Phase 7: Multi-Tenant SaaS
  final DateTime createdAt;
  final DateTime? updatedAt;

  CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = CampaignStatus.upcoming,
    required this.startDate,
    this.endDate,
    required this.location,
    this.latitude,
    this.longitude,
    this.coverImageUrl,
    this.posterImageUrl,
    this.videoUrl,
    this.documentUrl,
    this.galleryUrls = const [],
    required this.targetGoal,
    this.achievedGoal,
    this.itemsNeeded,
    this.requiredSkills = const [],
    this.totalVolunteers = 0,
    this.volunteerLimit,
    this.totalDonationsAmount = 0.0,
    this.totalDonationsCount = 0,
    this.beneficiaryCount = 0,
    this.distributionCount = 0,
    this.totalExpenses = 0.0,
    this.progressPercent = 0,
    required this.createdBy,
    required this.createdByName,
    this.ngoName,
    required this.ngoId,
    required this.createdAt,
    this.updatedAt,
  });

  /// From Firestore document
  factory CampaignModel.fromMap(Map<String, dynamic> map) {
    return CampaignModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: CampaignType.fromString(map['type'] ?? 'custom'),
      status: CampaignStatus.fromString(map['status'] ?? 'upcoming'),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      location: map['location'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      coverImageUrl: map['coverImageUrl'],
      posterImageUrl: map['posterImageUrl'],
      videoUrl: map['videoUrl'],
      documentUrl: map['documentUrl'],
      galleryUrls: List<String>.from(map['galleryUrls'] ?? []),
      targetGoal: map['targetGoal'] ?? '',
      achievedGoal: map['achievedGoal'],
      itemsNeeded: map['itemsNeeded'],
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      totalVolunteers: map['totalVolunteers'] ?? 0,
      volunteerLimit: map['volunteerLimit'],
      totalDonationsAmount: (map['totalDonationsAmount'] ?? 0).toDouble(),
      totalDonationsCount: map['totalDonationsCount'] ?? 0,
      beneficiaryCount: map['beneficiaryCount'] ?? 0,
      distributionCount: map['distributionCount'] ?? 0,
      totalExpenses: (map['totalExpenses'] ?? 0).toDouble(),
      progressPercent: map['progressPercent'] ?? 0,
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      ngoName: map['ngoName'],
      ngoId: map['ngoId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// To Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'coverImageUrl': coverImageUrl,
      'posterImageUrl': posterImageUrl,
      'videoUrl': videoUrl,
      'documentUrl': documentUrl,
      'galleryUrls': galleryUrls,
      'targetGoal': targetGoal,
      'achievedGoal': achievedGoal,
      'itemsNeeded': itemsNeeded,
      'requiredSkills': requiredSkills,
      'totalVolunteers': totalVolunteers,
      'volunteerLimit': volunteerLimit,
      'totalDonationsAmount': totalDonationsAmount,
      'totalDonationsCount': totalDonationsCount,
      'beneficiaryCount': beneficiaryCount,
      'distributionCount': distributionCount,
      'totalExpenses': totalExpenses,
      'progressPercent': progressPercent,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'ngoName': ngoName,
      'ngoId': ngoId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Copy with updated fields
  CampaignModel copyWith({
    String? title,
    String? description,
    CampaignType? type,
    CampaignStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    double? latitude,
    double? longitude,
    String? coverImageUrl,
    String? posterImageUrl,
    String? videoUrl,
    String? documentUrl,
    List<String>? galleryUrls,
    String? targetGoal,
    String? achievedGoal,
    String? itemsNeeded,
    List<String>? requiredSkills,
    int? totalVolunteers,
    int? volunteerLimit,
    double? totalDonationsAmount,
    int? totalDonationsCount,
    int? beneficiaryCount,
    int? distributionCount,
    double? totalExpenses,
    int? progressPercent,
    String? ngoName,
    String? ngoId,
  }) {
    return CampaignModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      posterImageUrl: posterImageUrl ?? this.posterImageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      targetGoal: targetGoal ?? this.targetGoal,
      achievedGoal: achievedGoal ?? this.achievedGoal,
      itemsNeeded: itemsNeeded ?? this.itemsNeeded,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      totalVolunteers: totalVolunteers ?? this.totalVolunteers,
      volunteerLimit: volunteerLimit ?? this.volunteerLimit,
      totalDonationsAmount: totalDonationsAmount ?? this.totalDonationsAmount,
      totalDonationsCount: totalDonationsCount ?? this.totalDonationsCount,
      beneficiaryCount: beneficiaryCount ?? this.beneficiaryCount,
      distributionCount: distributionCount ?? this.distributionCount,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      progressPercent: progressPercent ?? this.progressPercent,
      createdBy: createdBy,
      createdByName: createdByName,
      ngoName: ngoName ?? this.ngoName,
      ngoId: ngoId ?? this.ngoId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Helpers
  bool get isUpcoming => status == CampaignStatus.upcoming;
  bool get isActive => status == CampaignStatus.active;
  bool get isCompleted => status == CampaignStatus.completed;
  double get remainingBudget => totalDonationsAmount - totalExpenses;
  bool get hasVolunteerLimit => volunteerLimit != null && volunteerLimit! > 0;
  bool get isFull => hasVolunteerLimit && totalVolunteers >= volunteerLimit!;

  @override
  String toString() => 'CampaignModel(id: $id, title: $title, status: ${status.label})';
}
