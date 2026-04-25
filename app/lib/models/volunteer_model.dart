import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

/// Volunteer registration model — tracks who joined which campaign.
class VolunteerModel {
  final String id;
  final String campaignId;
  final String campaignTitle;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final VolunteerStatus status;
  final DateTime registeredAt;
  final DateTime? confirmedAt;
  final DateTime? attendedAt;
  final String? notes;

  VolunteerModel({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    this.status = VolunteerStatus.registered,
    required this.registeredAt,
    this.confirmedAt,
    this.attendedAt,
    this.notes,
  });

  factory VolunteerModel.fromMap(Map<String, dynamic> map) {
    return VolunteerModel(
      id: map['id'] ?? '',
      campaignId: map['campaignId'] ?? '',
      campaignTitle: map['campaignTitle'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'],
      status: VolunteerStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'registered'),
        orElse: () => VolunteerStatus.registered,
      ),
      registeredAt: (map['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (map['confirmedAt'] as Timestamp?)?.toDate(),
      attendedAt: (map['attendedAt'] as Timestamp?)?.toDate(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'status': status.name,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'attendedAt': attendedAt != null ? Timestamp.fromDate(attendedAt!) : null,
      'notes': notes,
    };
  }

  VolunteerModel copyWith({
    VolunteerStatus? status,
    DateTime? confirmedAt,
    DateTime? attendedAt,
    String? notes,
  }) {
    return VolunteerModel(
      id: id,
      campaignId: campaignId,
      campaignTitle: campaignTitle,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      status: status ?? this.status,
      registeredAt: registeredAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      attendedAt: attendedAt ?? this.attendedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Helpers
  bool get isRegistered => status == VolunteerStatus.registered;
  bool get isConfirmed => status == VolunteerStatus.confirmed;
  bool get hasAttended => status == VolunteerStatus.attended;
  bool get isAbsent => status == VolunteerStatus.absent;

  @override
  String toString() => 'VolunteerModel(user: $userName, campaign: $campaignTitle, status: ${status.label})';
}
