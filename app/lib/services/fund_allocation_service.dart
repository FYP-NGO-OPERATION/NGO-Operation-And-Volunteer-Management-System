import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';
import '../models/tracking_event_model.dart';
import 'package:uuid/uuid.dart';

class FundAllocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Allocates an expense across available donations in a campaign using FIFO.
  /// Generates tracking events for every donor whose funds are used.
  Future<void> allocateExpense({
    required String campaignId,
    required double expenseTotal,
    required String expenseName,
    String? vendor,
  }) async {
    if (expenseTotal <= 0) return;

    final batch = _db.batch();
    double amountLeftToCover = expenseTotal;

    // 1. Fetch donations for this campaign that have unspent funds (> 0)
    final snapshot = await _db
        .collection('donations')
        .where('campaignId', isEqualTo: campaignId)
        .get(); // We fetch all and filter locally to avoid complex index requirements

    List<DonationModel> unspentDonations = snapshot.docs
        .map((doc) => DonationModel.fromMap(doc.data()..['id'] = doc.id))
        .where((d) => d.remainingAmount > 0)
        .toList();

    // Order by receivedAt (oldest first - FIFO)
    unspentDonations.sort((a, b) => a.receivedAt.compareTo(b.receivedAt));

    // 2. Loop and Allocate
    for (var donation in unspentDonations) {
      if (amountLeftToCover <= 0) break;

      double amountToTake = 0;
      if (donation.remainingAmount >= amountLeftToCover) {
        // This donation can cover the rest of the expense
        amountToTake = amountLeftToCover;
        amountLeftToCover = 0;
      } else {
        // Take whatever is left in this donation
        amountToTake = donation.remainingAmount;
        amountLeftToCover -= donation.remainingAmount;
      }

      final newRemaining = donation.remainingAmount - amountToTake;

      // Update donation document
      final donationRef = _db.collection('donations').doc(donation.id);
      batch.update(donationRef, {'remainingAmount': newRemaining});

      // Generate tracking event for this specific donor
      String message = 'Supply Chain Verified: Rs. ${amountToTake.toStringAsFixed(0)} utilized for $expenseName.';
      if (vendor != null && vendor.isNotEmpty) {
        message += ' (Vendor: $vendor)';
      }

      final eventId = const Uuid().v4();
      final eventRef = _db.collection('donation_tracking_events').doc(eventId);
      
      final trackingEvent = TrackingEventModel(
        id: eventId,
        donationId: donation.id,
        title: expenseName,
        description: message,
        status: TrackingStatus.done,
        timestamp: DateTime.now(),
      );

      batch.set(eventRef, trackingEvent.toMap());
    }

    // 3. Commit the batch
    await batch.commit();
  }

  /// Transfers all leftover funds from a completed campaign to a new campaign.
  Future<void> transferLeftoverFunds({
    required String fromCampaignId,
    required String toCampaignId,
    required String toCampaignName,
  }) async {
    final batch = _db.batch();

    final snapshot = await _db
        .collection('donations')
        .where('campaignId', isEqualTo: fromCampaignId)
        .get();

    List<DonationModel> unspentDonations = snapshot.docs
        .map((doc) => DonationModel.fromMap(doc.data()..['id'] = doc.id))
        .where((d) => d.remainingAmount > 0)
        .toList();

    for (var donation in unspentDonations) {
      final amount = donation.remainingAmount;
      
      // Update donation document to reflect transfer (optionally you could zero it out and create a new donation in the new campaign, but for UTXO tracking, we just update the campaignId)
      final donationRef = _db.collection('donations').doc(donation.id);
      batch.update(donationRef, {
        'campaignId': toCampaignId,
        'campaignTitle': toCampaignName, // Optional if stored
      });

      // Generate tracking event
      final eventId = const Uuid().v4();
      final eventRef = _db.collection('donation_tracking_events').doc(eventId);
      
      final trackingEvent = TrackingEventModel(
        id: eventId,
        donationId: donation.id,
        title: 'Funds Transferred',
        description: 'Campaign ended. Your unspent Rs. ${amount.toStringAsFixed(0)} was securely transferred to: $toCampaignName.',
        status: TrackingStatus.done,
        timestamp: DateTime.now(),
      );

      batch.set(eventRef, trackingEvent.toMap());
    }

    await batch.commit();
  }
}
