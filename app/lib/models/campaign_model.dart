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
  final String? coverImageUrl;
  final String? posterImageUrl;
  final String targetGoal;
  final String? achievedGoal;
  final String? itemsNeeded;
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
    this.coverImageUrl,
    this.posterImageUrl,
    required this.targetGoal,
    this.achievedGoal,
    this.itemsNeeded,
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
      coverImageUrl: map['coverImageUrl'],
      posterImageUrl: map['posterImageUrl'],
      targetGoal: map['targetGoal'] ?? '',
      achievedGoal: map['achievedGoal'],
      itemsNeeded: map['itemsNeeded'],
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
      'coverImageUrl': coverImageUrl,
      'posterImageUrl': posterImageUrl,
      'targetGoal': targetGoal,
      'achievedGoal': achievedGoal,
      'itemsNeeded': itemsNeeded,
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
    String? coverImageUrl,
    String? posterImageUrl,
    String? targetGoal,
    String? achievedGoal,
    String? itemsNeeded,
    int? totalVolunteers,
    int? volunteerLimit,
    double? totalDonationsAmount,
    int? totalDonationsCount,
    int? beneficiaryCount,
    int? distributionCount,
    double? totalExpenses,
    int? progressPercent,
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
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      posterImageUrl: posterImageUrl ?? this.posterImageUrl,
      targetGoal: targetGoal ?? this.targetGoal,
      achievedGoal: achievedGoal ?? this.achievedGoal,
      itemsNeeded: itemsNeeded ?? this.itemsNeeded,
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
