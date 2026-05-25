import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/app_enums.dart';

/// One-time demo data seeder for FYP defense presentation.
/// Seeds realistic campaigns so the dashboard doesn't look empty.
class DataSeederService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check if data has already been seeded
  static Future<bool> isAlreadySeeded() async {
    final campaigns = await _db.collection('campaigns').limit(1).get();
    return campaigns.docs.isNotEmpty;
  }

  /// Seed sample campaigns for demo
  static Future<int> seedCampaigns(String createdByUid, String createdByName) async {
    final campaigns = _getSampleCampaigns(createdByUid, createdByName);
    int count = 0;

    for (final data in campaigns) {
      final docRef = _db.collection('campaigns').doc();
      data['id'] = docRef.id;
      await docRef.set(data);
      count++;
    }

    return count;
  }

  /// Update a user's profile with demo skills and address
  static Future<void> enrichUserProfile(String uid) async {
    await _db.collection('users').doc(uid).update({
      'skills': ['medical', 'first aid', 'teaching', 'driving', 'food distribution'],
      'address': 'Multan, Punjab',
      'phone': '03001234567',
    });
  }

  /// Generate realistic sample campaigns as raw maps
  static List<Map<String, dynamic>> _getSampleCampaigns(String createdBy, String createdByName) {
    final now = DateTime.now();
    return [
      {
        'id': '',
        'title': 'Winter Clothes Distribution 2026',
        'description': 'Distributing warm clothes, blankets, and essentials to underprivileged families in South Punjab. '
            'Join us in making this winter warmer for those in need. We aim to serve 500+ families across Multan division.',
        'type': CampaignType.winterDrive.name,
        'status': CampaignStatus.active.name,
        'location': 'Multan, Punjab',
        'targetGoal': '500 Families',
        'targetVolunteers': 50,
        'totalVolunteers': 12,
        'totalDonationsAmount': 45000.0,
        'totalDonationsCount': 8,
        'beneficiaryCount': 120,
        'distributionCount': 3,
        'totalExpenses': 32000.0,
        'progressPercent': 24,
        'startDate': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 25))),
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': '',
        'title': 'Free Medical Camp - Basti Malook',
        'description': 'Free medical checkup camp for residents of Basti Malook and surrounding areas. '
            'Services include general checkup, blood pressure screening, blood sugar test, and free medicine distribution. '
            'Doctors and medical students are encouraged to volunteer.',
        'type': CampaignType.medical.name,
        'status': CampaignStatus.active.name,
        'location': 'Multan, Punjab',
        'targetGoal': '300 Patients',
        'targetVolunteers': 30,
        'totalVolunteers': 8,
        'totalDonationsAmount': 25000.0,
        'totalDonationsCount': 5,
        'beneficiaryCount': 85,
        'distributionCount': 1,
        'totalExpenses': 18000.0,
        'progressPercent': 28,
        'startDate': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 12))),
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': '',
        'title': 'Ramadan Ration Drive 2026',
        'description': 'Monthly ration package distribution for deserving families during the holy month of Ramadan. '
            'Each package contains 10kg flour, 5kg rice, 2kg sugar, cooking oil, dates, and other essentials.',
        'type': CampaignType.ramadan.name,
        'status': CampaignStatus.active.name,
        'location': 'Lahore, Punjab',
        'targetGoal': '1000 Packages',
        'targetVolunteers': 100,
        'totalVolunteers': 35,
        'totalDonationsAmount': 150000.0,
        'totalDonationsCount': 22,
        'beneficiaryCount': 400,
        'distributionCount': 5,
        'totalExpenses': 120000.0,
        'progressPercent': 40,
        'startDate': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 20))),
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 12))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': '',
        'title': 'Tree Plantation Drive - Multan',
        'description': 'Join HRAS in planting 1000 trees across Multan city parks and schools. '
            'Help make our city greener and fight climate change one tree at a time.',
        'type': CampaignType.plantation.name,
        'status': CampaignStatus.active.name,
        'location': 'Multan, Punjab',
        'targetGoal': '1000 Trees',
        'targetVolunteers': 40,
        'totalVolunteers': 15,
        'totalDonationsAmount': 12000.0,
        'totalDonationsCount': 3,
        'beneficiaryCount': 0,
        'distributionCount': 0,
        'totalExpenses': 8000.0,
        'progressPercent': 35,
        'startDate': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 30))),
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': '',
        'title': 'Orphanage Visit & Support Program',
        'description': 'Visit to Dar-ul-Atfal orphanage with gifts, clothes, and educational supplies. '
            'Spend quality time with the children and bring smiles to their faces.',
        'type': CampaignType.orphanage.name,
        'status': CampaignStatus.completed.name,
        'location': 'Multan, Punjab',
        'targetGoal': '50 Children',
        'targetVolunteers': 20,
        'totalVolunteers': 20,
        'totalDonationsAmount': 35000.0,
        'totalDonationsCount': 12,
        'beneficiaryCount': 50,
        'distributionCount': 2,
        'totalExpenses': 30000.0,
        'progressPercent': 100,
        'startDate': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        'endDate': Timestamp.fromDate(now.subtract(const Duration(days: 25))),
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 35))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];
  }
}
