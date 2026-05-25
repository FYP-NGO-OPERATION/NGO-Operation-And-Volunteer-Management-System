import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';

class LiveMissionMapScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;
  final double? initialLat;
  final double? initialLng;

  const LiveMissionMapScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<LiveMissionMapScreen> createState() => _LiveMissionMapScreenState();
}

class _LiveMissionMapScreenState extends State<LiveMissionMapScreen> {
  @override
  Widget build(BuildContext context) {
    final initialCenter = widget.initialLat != null && widget.initialLng != null
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : const LatLng(31.5204, 74.3587); // Default Lahore

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Mission: ${widget.campaignTitle}'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('campaigns')
            .doc(widget.campaignId)
            .collection('live_tracking')
            .snapshots(),
        builder: (context, snapshot) {
          List<Marker> markers = [];
          if (snapshot.hasData) {
            markers = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final double lat = data['lat'] ?? 0.0;
              final double lng = data['lng'] ?? 0.0;
              final bool isFatigued = data['isFatigued'] ?? false;
              final String name = data['userName'] ?? 'Volunteer';

              return Marker(
                point: LatLng(lat, lng),
                width: 60,
                height: 60,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isFatigued ? AppColors.error : AppColors.primary),
                      ),
                      child: Text(
                        name.split(' ').first,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFatigued ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.person_pin_circle,
                      color: isFatigued ? AppColors.error : AppColors.primary,
                      size: 40,
                    ),
                  ],
                ),
              );
            }).toList();
          }

          return Stack(
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
                  MarkerLayer(markers: markers),
                ],
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator()),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.satellite_alt, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Active Volunteers: ${markers.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
