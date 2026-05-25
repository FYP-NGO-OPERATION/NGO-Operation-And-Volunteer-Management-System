import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  final Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
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
          if (snapshot.hasData) {
            _updateMarkers(snapshot.data!.docs);
          }

          final initialCameraPosition = CameraPosition(
            target: widget.initialLat != null && widget.initialLng != null
                ? LatLng(widget.initialLat!, widget.initialLng!)
                : const LatLng(31.5204, 74.3587), // Default Lahore
            zoom: 12,
          );

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: Set<Marker>.of(_markers.values),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
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
                        'Active Volunteers: ${_markers.length}',
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

  void _updateMarkers(List<QueryDocumentSnapshot> docs) {
    final newMarkers = <String, Marker>{};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;
      final userName = data['userName'] as String? ?? 'Volunteer';
      
      DateTime startTime = DateTime.now();
      if (data['startTime'] != null) {
        startTime = (data['startTime'] as Timestamp).toDate();
      } else if (data['timestamp'] != null) {
        startTime = (data['timestamp'] as Timestamp).toDate();
      }

      final hoursActive = DateTime.now().difference(startTime).inHours;
      bool isFatigued = hoursActive >= 8; // Assuming 8 hours shift

      if (lat != null && lng != null) {
        final markerId = MarkerId(doc.id);
        newMarkers[doc.id] = Marker(
          markerId: markerId,
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: '$userName ${isFatigued ? "⚠️ FATIGUED" : ""}', 
            snippet: 'Active for $hoursActive hours',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isFatigued ? BitmapDescriptor.hueRed : BitmapDescriptor.hueAzure
          ),
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(newMarkers);
        });
      }
    });
  }
}
