import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentModel {
  final String id;
  final String reportedByUserId;
  final String reportedByUserName;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime reportedAt;
  final bool isResolved;

  IncidentModel({
    required this.id,
    required this.reportedByUserId,
    required this.reportedByUserName,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.reportedAt,
    this.isResolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportedByUserId': reportedByUserId,
      'reportedByUserName': reportedByUserName,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'isResolved': isResolved,
    };
  }

  factory IncidentModel.fromMap(Map<String, dynamic> map) {
    return IncidentModel(
      id: map['id'] ?? '',
      reportedByUserId: map['reportedByUserId'] ?? '',
      reportedByUserName: map['reportedByUserName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      reportedAt: (map['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isResolved: map['isResolved'] ?? false,
    );
  }
}

class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generateId() => _db.collection('incidents').doc().id;

  Future<void> reportIncident(IncidentModel incident) async {
    await _db.collection('incidents').doc(incident.id).set(incident.toMap());
  }

  Stream<List<IncidentModel>> getActiveIncidents() {
    return _db
        .collection('incidents')
        .where('isResolved', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IncidentModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> resolveIncident(String id) async {
    await _db.collection('incidents').doc(id).update({'isResolved': true});
  }
}
