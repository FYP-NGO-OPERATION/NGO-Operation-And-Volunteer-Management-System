const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 1. Notify all users when an Announcement is created
exports.onAnnouncementCreated = functions.firestore
  .document("announcements/{announcementId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    const payload = {
      notification: {
        title: data.title || "New Update from HRAS",
        body: data.description || "Check out the latest announcement in the app.",
        sound: "default",
      },
      topic: "campaigns"
    };

    try {
      await admin.messaging().send(payload);
      console.log("Successfully sent announcement notification");
    } catch (error) {
      console.error("Error sending announcement notification:", error);
    }
  });

// 2. Notify all users when a new Campaign is created
exports.onCampaignCreated = functions.firestore
  .document("campaigns/{campaignId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    const payload = {
      notification: {
        title: "New Campaign: " + (data.title || ""),
        body: "A new campaign has been added in " + (data.location || "your area") + ". Join now to earn points!",
        sound: "default",
      },
      topic: "campaigns"
    };

    try {
      await admin.messaging().send(payload);
      console.log("Successfully sent campaign notification");
    } catch (error) {
      console.error("Error sending campaign notification:", error);
    }
  });

// 3. SOS Alert Notification
exports.onSosCreated = functions.firestore
  .document("sos_alerts/{sosId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userName = data.userName || "A volunteer";
    
    const payload = {
      notification: {
        title: "EMERGENCY SOS! ??",
        body: userName + " has triggered an emergency SOS! Please check the disaster map immediately.",
        sound: "default",
      },
      topic: "campaigns", // Send to all subscribed volunteers and admins
      android: {
        priority: "high",
        notification: {
            channelId: "high_importance_channel"
        }
      }
    };

    try {
      await admin.messaging().send(payload);
      console.log("Successfully sent SOS notification");
    } catch (error) {
      console.error("Error sending SOS notification:", error);
    }
  });

// 4. Notify Admins on E-Store Purchase
exports.onOrderCreated = functions.firestore
  .document("admin_notifications/{notifId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // For simplicity, we send this to the 'admin' topic.
    // The flutter app will need to subscribe admins to this topic.
    const payload = {
      notification: {
        title: data.title || "New Notification",
        body: data.body || "",
        sound: "default",
      },
      topic: "admin"
    };

    try {
      await admin.messaging().send(payload);
      console.log("Successfully sent admin notification");
    } catch (error) {
      console.error("Error sending admin notification:", error);
    }
  });
