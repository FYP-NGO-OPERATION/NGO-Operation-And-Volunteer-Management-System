import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngo_volunteer_app/enums/app_enums.dart';
import 'package:ngo_volunteer_app/models/donation_model.dart';
import 'package:ngo_volunteer_app/services/donation_service.dart';

void main() {
  group('DonationService Business Logic', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DonationService donationService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      donationService = DonationService(db: fakeFirestore);
    });

    test('addDonation correctly inserts record and updates campaign if approved', () async {
      final campaignId = 'camp123';
      
      // Seed a campaign
      await fakeFirestore.collection('campaigns').doc(campaignId).set({
        'title': 'Test Campaign',
        'totalDonationsCount': 0,
        'totalDonationsAmount': 0.0,
      });

      final newDonation = DonationModel(
        id: '',
        campaignId: campaignId,
        campaignTitle: 'Test Campaign',
        donorName: 'John Doe',
        donorPhone: '1234567890',
        donorCnic: '12345-1234567-1',
        category: DonationCategory.money,
        quantity: '1',
        amount: 5000,
        amountCash: 5000,
        amountOnline: 0,
        paymentMethod: PaymentMethod.cash,
        purpose: 'Test Donation',
        description: 'Testing',
        receivedBy: 'admin1',
        receivedByName: 'Admin',
        receivedAt: DateTime.now(),
        transactionId: 'TX123',
        status: DonationStatus.approved,
        isAnonymous: false,
      );

      final result = await donationService.addDonation(newDonation);

      // Verify the donation exists in Firestore
      final doc = await fakeFirestore.collection('donations').doc(result.id).get();
      expect(doc.exists, true);
      expect(doc.data()?['status'], 'approved');

      // Verify campaign counters incremented
      final campDoc = await fakeFirestore.collection('campaigns').doc(campaignId).get();
      expect(campDoc.data()?['totalDonationsCount'], 1);
      expect(campDoc.data()?['totalDonationsAmount'], 5000);
    });

    test('updateDonationStatus respects idempotency and updates counters', () async {
      final campaignId = 'camp123';
      
      // Seed a campaign
      await fakeFirestore.collection('campaigns').doc(campaignId).set({
        'title': 'Test Campaign',
        'totalDonationsCount': 0,
        'totalDonationsAmount': 0.0,
      });

      // Seed a pending donation
      final donationId = 'don123';
      final donation = DonationModel(
        id: donationId,
        campaignId: campaignId,
        campaignTitle: 'Test Campaign',
        donorName: 'John Doe',
        donorPhone: '1234567890',
        donorCnic: '12345-1234567-1',
        category: DonationCategory.money,
        quantity: '1',
        amount: 5000,
        amountCash: 5000,
        amountOnline: 0,
        paymentMethod: PaymentMethod.cash,
        purpose: 'Test',
        description: 'Test',
        receivedBy: 'admin1',
        receivedByName: 'Admin',
        receivedAt: DateTime.now(),
        transactionId: 'TX123',
        status: DonationStatus.pending,
        isAnonymous: false,
      );

      await fakeFirestore.collection('donations').doc(donationId).set(donation.toMap());

      // Update to approved
      await donationService.updateDonationStatus(donation, DonationStatus.approved);

      // Verify counters incremented
      var campDoc = await fakeFirestore.collection('campaigns').doc(campaignId).get();
      expect(campDoc.data()?['totalDonationsCount'], 1);
      expect(campDoc.data()?['totalDonationsAmount'], 5000);

      // Update to rejected (from approved)
      final approvedDonation = DonationModel(
        id: donation.id,
        campaignId: donation.campaignId,
        campaignTitle: donation.campaignTitle,
        donorName: donation.donorName,
        category: donation.category,
        quantity: donation.quantity,
        amount: donation.amount,
        amountCash: donation.amountCash,
        amountOnline: donation.amountOnline,
        paymentMethod: donation.paymentMethod,
        receivedBy: donation.receivedBy,
        receivedByName: donation.receivedByName,
        receivedAt: donation.receivedAt,
        status: DonationStatus.approved,
      );
      await donationService.updateDonationStatus(approvedDonation, DonationStatus.rejected);

      // Verify counters decremented
      campDoc = await fakeFirestore.collection('campaigns').doc(campaignId).get();
      expect(campDoc.data()?['totalDonationsCount'], 0);
      expect(campDoc.data()?['totalDonationsAmount'], 0.0);
    });
  });
}
