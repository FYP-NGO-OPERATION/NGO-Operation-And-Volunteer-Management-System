import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/disaster_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DisasterMapScreen extends StatelessWidget {
  const DisasterMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final disasterProvider = Provider.of<DisasterProvider>(context);
    final bool isEmergency = disasterProvider.isEmergencyMode;

    // Center on Karachi for FYP
    final initialCenter = const LatLng(24.8607, 67.0011);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (isEmergency) const Icon(Icons.warning, color: Colors.white),
            if (isEmergency) const SizedBox(width: 8),
            Text(isEmergency ? 'DISASTER RELIEF MODE' : 'Normal Map Mode'),
          ],
        ),
        backgroundColor: isEmergency ? AppColors.error : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.hras.volunteer',
              ),
              if (isEmergency)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: const LatLng(24.86, 67.01),
                      color: Colors.red.withValues(alpha: 0.4),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: 2000, 
                    ),
                    CircleMarker(
                      point: const LatLng(24.82, 67.05),
                      color: Colors.green.withValues(alpha: 0.4),
                      borderColor: Colors.green,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: 1500, // Safe Zone
                    ),
                  ],
                ),
              if (isEmergency)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(24.86, 67.01),
                      child: const Icon(Icons.warning, color: Colors.red, size: 40),
                    ),
                    Marker(
                      point: const LatLng(24.82, 67.05),
                      child: const Icon(Icons.health_and_safety, color: Colors.green, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          if (isEmergency)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DANGER ZONE IDENTIFIED. AVOID RED AREAS. SEEK REFUGE IN GREEN ZONES.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isEmergency ? FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SOS Pin Dropped! Rescue team notified.'), backgroundColor: Colors.red),
          );
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.sos, color: Colors.white),
        label: const Text('Drop SOS Pin', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }
}
