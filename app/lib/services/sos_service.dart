import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class SosService {
  static Future<void> sendSosAlert(String userId, String userName) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable them to send SOS.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance.collection('sos_alerts').add({
      'userId': userId,
      'userName': userName,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'active', // active, resolved
    });
  }
}
