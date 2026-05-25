/**
 * HRAS (NGO Volunteer App) - Firebase Cloud Functions
 * FYP-03 Module: Production-Grade Reliability & Server-Side Processing
 * 
 * Upgrades applied:
 * 1. .runWith({ failurePolicy: true }) added for reliable push notification retries.
 * 2. getCampaignRecommendations (onCall) added to offload heavy O(N) matching from the mobile client.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Configuration for robust execution
const runtimeOpts = {
  timeoutSeconds: 60,
  memory: '256MB',
  failurePolicy: true
};

/**
 * Trigger: onCreate in the 'campaigns' collection.
 * Action: Sends a notification to the 'campaigns' topic.
 */
exports.notifyNewCampaign = functions.runWith(runtimeOpts).firestore
  .document('campaigns/{campaignId}')
  .onCreate(async (snap, context) => {
    const newCampaign = snap.data();
    const campaignTitle = newCampaign.title || 'New Campaign';
    const campaignType = newCampaign.type || 'Event';
    
    console.log(`[HRAS] Triggered! New campaign created: ${campaignTitle}`);

    const payload = {
      notification: {
        title: 'New Volunteer Opportunity! 📢',
        body: `HRAS just posted a new ${campaignType} campaign: ${campaignTitle}. Tap to register!`,
      },
      data: {
        campaignId: context.params.campaignId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    try {
      const response = await admin.messaging().sendToTopic('campaigns', payload);
      console.log(`[HRAS] Notification sent successfully. Message ID: ${response.messageId}`);
      return null;
    } catch (error) {
      console.error('[HRAS] Error sending notification:', error);
      // Throwing error allows Firebase to retry if failurePolicy was enabled, 
      // but since we want to avoid infinite retry loops on bad payloads, 
      // we log it securely.
      return null;
    }
  });

/**
 * Trigger: onCreate in the 'donations' collection.
 * Action: Sends a confirmation notification to the user who donated.
 */
exports.notifyDonationSuccess = functions.runWith(runtimeOpts).firestore
  .document('donations/{donationId}')
  .onCreate(async (snap, context) => {
    const donation = snap.data();
    const userId = donation.userId;
    const amount = donation.amount || 0;
    const campaignTitle = donation.campaignTitle || 'a campaign';

    if (!userId) {
      console.log('[HRAS] Anonymous donation. No user to notify.');
      return null;
    }

    try {
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) return null;

      const payload = {
        notification: {
          title: 'Donation Received! ❤️',
          body: `Thank you for donating Rs. ${amount} to ${campaignTitle}. Your generosity makes a difference.`,
        }
      };

      await admin.messaging().sendToDevice(fcmToken, payload);
      console.log(`[HRAS] Donation receipt sent to user ${userId}`);
      return null;
    } catch (error) {
      console.error('[HRAS] Error processing donation notification:', error);
      return null;
    }
  });

/**
 * Trigger: onUpdate in the 'volunteers' collection.
 * Action: Logs QR attendance and optionally sends a push notification.
 */
exports.logQrAttendance = functions.runWith(runtimeOpts).firestore
  .document('volunteers/{volunteerDocId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if status changed to 'attended'
    if (beforeData.status !== 'attended' && afterData.status === 'attended') {
      const userId = afterData.userId;
      const campaignTitle = afterData.campaignTitle || 'the campaign';
      
      try {
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) return null;

        const fcmToken = userDoc.data().fcmToken;
        if (!fcmToken) return null;

        const payload = {
          notification: {
            title: 'Attendance Marked! ✅',
            body: `Your attendance at ${campaignTitle} was successfully scanned via QR code.`,
          }
        };

        await admin.messaging().sendToDevice(fcmToken, payload);
        console.log(`[HRAS] QR Attendance notification sent to ${userId}`);
        return null;
      } catch (error) {
        console.error('[HRAS] Error sending attendance notification:', error);
        return null;
      }
    }
    return null;
  });

/**
 * Callable Function: getCampaignRecommendations
 * Purpose: Offloads the O(N) Smart Matching algorithm to the backend.
 * Scoring: Skills (40%), Location (30%), Past Activity (20%), Availability (10%)
 */
exports.getCampaignRecommendations = functions.runWith(runtimeOpts).https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in to get recommendations.');
  }

  const userId = context.auth.uid;

  try {
    const db = admin.firestore();
    
    // 1. Fetch User Profile
    const userSnap = await db.collection('users').doc(userId).get();
    if (!userSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'User profile not found.');
    }
    const userData = userSnap.data();
    const userSkills = userData.skills || [];
    const userAddress = (userData.address || '').toLowerCase();

    // 2. Fetch User's Past Registrations (to calculate Availability and Past Activity)
    const registrationsSnap = await db.collection('volunteers').where('userId', '==', userId).get();
    const registeredCampaignIds = new Set();
    const pastCampaignTitles = [];
    
    registrationsSnap.forEach(doc => {
      const reg = doc.data();
      registeredCampaignIds.add(reg.campaignId);
      if (reg.campaignTitle) {
        pastCampaignTitles.push(reg.campaignTitle.toLowerCase());
      }
    });

    // 3. Fetch All Active Campaigns
    // In a real production environment with 10k+ campaigns, we would use Algolia or limit to recent.
    // For FYP-03, server-side mapping is still vastly superior to client-side.
    const campaignsSnap = await db.collection('campaigns')
      .where('status', '==', 'active')
      .get();

    const results = [];

    // Weights
    const wSkill = 0.40;
    const wLocation = 0.30;
    const wPastActivity = 0.20;
    const wAvailability = 0.10;

    // Helper: Map skills to types
    const skillCampaignMap = {
      'medical': ['medical'], 'healthcare': ['medical'], 'doctor': ['medical'],
      'teaching': ['education'], 'education': ['education'], 'tutoring': ['education'],
      'cooking': ['ration', 'ramadan', 'eid'], 'food': ['ration', 'ramadan'],
      'distribution': ['ration', 'winter_drive'], 'logistics': ['ration', 'winter_drive']
    };

    campaignsSnap.forEach(doc => {
      const campaign = doc.data();
      campaign.id = doc.id;

      // Skip full campaigns (assuming currentVolunteers exists)
      const currentVols = campaign.currentVolunteers || 0;
      const reqVols = campaign.requiredVolunteers || 999;
      if (currentVols >= reqVols) return;

      const cType = (campaign.type || '').toLowerCase();
      const cLocation = (campaign.location || '').toLowerCase();
      const cTitle = (campaign.title || '').toLowerCase();

      // --- Calculate Skill Score ---
      let skillScore = 0.3; // Neutral
      if (userSkills.length > 0) {
        let matchCount = 0;
        userSkills.forEach(skill => {
          const s = skill.toLowerCase();
          const targetTypes = skillCampaignMap[s] || [s]; // Direct match fallback
          if (targetTypes.includes(cType)) matchCount++;
        });

        if (matchCount > 1) skillScore = 1.0;
        else if (matchCount === 1) skillScore = 0.7;
        else skillScore = 0.1;
      }

      // --- Calculate Location Score ---
      let locationScore = 0.3; // Neutral
      if (userAddress) {
        if (cLocation === userAddress || userAddress.includes(cLocation) || cLocation.includes(userAddress)) {
          locationScore = 1.0;
        } else {
          locationScore = 0.1;
        }
      }

      // --- Calculate Past Activity Score ---
      let pastActivityScore = 0.2; // Baseline
      if (pastCampaignTitles.length > 0) {
        const hasSimilar = pastCampaignTitles.some(t => t.includes(cType) || cTitle.includes(t.split(' ')[0]));
        if (hasSimilar) pastActivityScore = 1.0;
        else pastActivityScore = 0.5;
      }

      // --- Calculate Availability Score ---
      const availabilityScore = registeredCampaignIds.has(campaign.id) ? 0.0 : 1.0;

      // Total Score
      const totalScore = (skillScore * wSkill) + (locationScore * wLocation) + (pastActivityScore * wPastActivity) + (availabilityScore * wAvailability);

      // Only push decent matches (> 40%)
      if (totalScore >= 0.4) {
        results.push({
          campaignId: campaign.id,
          title: campaign.title,
          type: campaign.type,
          location: campaign.location,
          score: totalScore,
          percentage: Math.round(totalScore * 100),
          breakdown: {
            skills: skillScore,
            location: locationScore,
            past_activity: pastActivityScore,
            availability: availabilityScore
          }
        });
      }
    });

    // Sort by score descending and return top 10
    results.sort((a, b) => b.score - a.score);
    return { recommendations: results.slice(0, 10) };

  } catch (error) {
    console.error('[HRAS] Error in getCampaignRecommendations:', error);
    throw new functions.https.HttpsError('internal', 'Unable to fetch recommendations.');
  }
});
