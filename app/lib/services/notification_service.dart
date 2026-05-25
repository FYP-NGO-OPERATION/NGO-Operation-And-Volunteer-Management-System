import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Firebase Cloud Messaging (FCM) Notification Service (FYP-02 Feature Module).
///
/// ARCHITECTURE: Token-Based + Topic-Based Push Notifications
///
/// Initialization Flow (called from SplashScreen after auth):
///   1. Request notification permission from the OS
///   2. Obtain unique FCM device token from Firebase
///   3. Store token in user's Firestore document (for targeted notifications)
///   4. Subscribe to 'campaigns' topic (for broadcast notifications)
///   5. Register foreground message handler
///
/// Notification Types:
///   - TOPIC-BASED: All users subscribed to 'campaigns' topic receive
///     broadcast notifications (e.g., new campaign created)
///   - TOKEN-BASED: Individual notifications using stored FCM token
///     (e.g., volunteer assigned to campaign)
///
/// Server-Side (Future Enhancement):
///   - Firebase Cloud Functions would trigger notifications on Firestore events
///   - Currently, token registration and topic subscription are implemented
///   - Server-side message sending requires Cloud Functions deployment
///
/// Feature Gate: Only initialized when FeatureFlags.isPushNotificationsEnabled == true
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize FCM — call once after Firebase.initializeApp().
  Future<void> initialize(String userId) async {
    if (_initialized) return;

    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('[FCM] User declined notification permissions');
        return;
      }

      // Initialize local notifications for foreground display
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: darwinInit);
      await _localNotifications.initialize(settings: initSettings);

      // Create a high importance channel for Android
      const channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', // description
        importance: Importance.max,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Get and store FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _storeFcmToken(userId, token);
        debugPrint('[FCM] Token registered for user $userId');
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _storeFcmToken(userId, newToken);
      });

      // Subscribe to global campaign topic
      await _messaging.subscribeToTopic('campaigns');
      debugPrint('[FCM] Subscribed to campaigns topic');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      _initialized = true;
      debugPrint('[FCM] Notification service initialized');
    } catch (e) {
      debugPrint('[FCM] Initialization failed: $e');
    }
  }

  /// Store the FCM token in the user's Firestore document.
  Future<void> _storeFcmToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[FCM] Failed to store token: $e');
    }
  }

  /// Handle incoming messages while app is in foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  /// Unsubscribe from all topics (used on logout).
  Future<void> unsubscribe() async {
    try {
      await _messaging.unsubscribeFromTopic('campaigns');
      await _messaging.deleteToken();
      _initialized = false;
      debugPrint('[FCM] Unsubscribed and token deleted');
    } catch (e) {
      debugPrint('[FCM] Unsubscribe failed: $e');
    }
  }
}
