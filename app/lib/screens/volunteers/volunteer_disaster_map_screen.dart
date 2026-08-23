import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/disaster_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/incident_model.dart';
import 'dart:async';

class VolunteerDisasterMapScreen extends StatefulWidget {
  const VolunteerDisasterMapScreen({super.key});

  @override
  State<VolunteerDisasterMapScreen> createState() => _VolunteerDisasterMapScreenState();
}

class _VolunteerDisasterMapScreenState extends State<VolunteerDisasterMapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _volunteerLocation;
  List<LatLng> _currentRoute = [];
  bool _isLoadingRoute = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        _volunteerLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_volunteerLocation!, 13.0);
    }
  }

  Future<void> _fetchRoute(LatLng destination) async {
    if (_volunteerLocation == null) return;
    setState(() => _isLoadingRoute = true);
    
    final provider = Provider.of<DisasterProvider>(context, listen: false);
    final route = await provider.getOptimizedRoute(_volunteerLocation!, destination);
    
    if (mounted) {
      setState(() {
        _currentRoute = route;
        _isLoadingRoute = false;
      });
      // Zoom out to fit both points
      if (route.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints([_volunteerLocation!, destination]);
        _mapController.fitCamera(CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'EMERGENCY DISPATCH',
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.emergencyGradient,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(30.3753, 69.3451), // Pakistan default
              initialZoom: 5.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.hras.volunteer',
              ),
              if (_currentRoute.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _currentRoute,
                      color: AppColors.accent,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              StreamBuilder<List<IncidentModel>>(
                stream: IncidentService().getActiveIncidents(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final incidents = snapshot.data!;
                  
                  return MarkerLayer(
                    markers: incidents.map((incident) {
                      final pos = LatLng(incident.latitude, incident.longitude);
                      return Marker(
                        point: pos,
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => _fetchRoute(pos),
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.error.withOpacity(0.3),
                                border: Border.all(color: AppColors.error, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.error.withOpacity(0.8),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.warning, color: Colors.white, size: 30),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              if (_volunteerLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _volunteerLocation!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.info.withOpacity(0.3),
                          border: Border.all(color: AppColors.info, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoadingRoute)
            const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (_volunteerLocation != null) {
            _mapController.move(_volunteerLocation!, 15.0);
          }
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
