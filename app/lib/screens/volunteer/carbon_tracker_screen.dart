import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CarbonTrackerScreen extends StatefulWidget {
  const CarbonTrackerScreen({super.key});

  @override
  State<CarbonTrackerScreen> createState() => _CarbonTrackerScreenState();
}

class _CarbonTrackerScreenState extends State<CarbonTrackerScreen> {
  bool _isTracking = false;
  Position? _startPosition;
  double _totalDistanceMeters = 0.0;
  StreamSubscription<Position>? _positionStream;

  // Assume 0.12 kg CO2 saved per km by walking/cycling instead of driving
  double get _co2Saved => (_totalDistanceMeters / 1000) * 0.12; 

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      // Stop tracking
      _positionStream?.cancel();
      setState(() {
        _isTracking = false;
      });
      // Here you would save _co2Saved to Firestore user profile
    } else {
      // Start tracking
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      
      setState(() {
        _startPosition = position;
        _totalDistanceMeters = 0.0;
        _isTracking = true;
      });

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((Position newPosition) {
        if (_startPosition != null) {
          final distance = Geolocator.distanceBetween(
            _startPosition!.latitude,
            _startPosition!.longitude,
            newPosition.latitude,
            newPosition.longitude,
          );
          setState(() {
            _totalDistanceMeters += distance;
            _startPosition = newPosition; // Update for next segment
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carbon Footprint Tracker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                'Track your eco-friendly volunteer journey.',
                style: AppTextStyles.titleMedium(color: Colors.blueGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Text(
                '${(_totalDistanceMeters / 1000).toStringAsFixed(2)} KM',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const Text('Distance Covered'),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_co2Saved.toStringAsFixed(3)} kg',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const Text('CO2 Emissions Saved', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(_isTracking ? 'Stop Tracking' : 'Start Journey'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleTracking,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
