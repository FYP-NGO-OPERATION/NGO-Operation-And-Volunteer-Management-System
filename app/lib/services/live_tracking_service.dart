import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTrackingService {
  static final LiveTrackingService _instance = LiveTrackingService._internal();
  factory LiveTrackingService() => _instance;
  LiveTrackingService._internal();

  StreamSubscription<Position>? _positionStream;
  String? _currentCampaignId;
  String? _currentUserId;

  bool get isTracking => _positionStream != null;

  Future<void> startTracking(
    String campaignId,
    String userId,
    String userName,
  ) async {
    if (isTracking) return;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    _currentCampaignId = campaignId;
    _currentUserId = userId;

    // Start listening to location updates
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // update every 10 meters
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            if (position != null) {
              _updateLocationInFirestore(position, userName);
            }
          },
        );

    // Initial update
    Position initialPos = await Geolocator.getCurrentPosition();
    _updateLocationInFirestore(initialPos, userName);
  }

  Future<void> stopTracking() async {
    if (_positionStream != null) {
      await _positionStream!.cancel();
      _positionStream = null;
    }

    if (_currentCampaignId != null && _currentUserId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('campaigns')
            .doc(_currentCampaignId)
            .collection('live_tracking')
            .doc(_currentUserId)
            .delete();
      } catch (e) {
        // ignore
      }
    }

    _currentCampaignId = null;
    _currentUserId = null;
  }

  Future<void> _updateLocationInFirestore(
    Position position,
    String userName,
  ) async {
    if (_currentCampaignId == null || _currentUserId == null) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('campaigns')
          .doc(_currentCampaignId)
          .collection('live_tracking')
          .doc(_currentUserId);

      final docSnap = await docRef.get();
      DateTime? startTime;
      if (docSnap.exists && docSnap.data()!.containsKey('startTime')) {
        startTime = (docSnap.data()!['startTime'] as Timestamp).toDate();
      } else {
        startTime = DateTime.now();
      }

      await docRef.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'startTime': Timestamp.fromDate(startTime),
        'userName': userName,
        'speed': position.speed,
        'heading': position.heading,
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore
    }
  }
}
