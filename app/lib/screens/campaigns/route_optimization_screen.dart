import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

class RouteOptimizationScreen extends StatefulWidget {
  const RouteOptimizationScreen({super.key});

  @override
  State<RouteOptimizationScreen> createState() => _RouteOptimizationScreenState();
}

class _RouteOptimizationScreenState extends State<RouteOptimizationScreen> {
  List<LatLng> _stops = [];
  List<LatLng> _optimizedRoute = [];
  bool _isOptimizing = false;
  bool _isLoadingMap = true;
  double _totalDistance = 0.0;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchCampaignLocations();
  }

  Future<void> _fetchCampaignLocations() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('campaigns').where('status', isEqualTo: 'active').get();
      List<LatLng> fetchedStops = [];
      
      loc.Location location = loc.Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }
      
      final pos = serviceEnabled ? await LocationService.getCurrentLocation() : null;
      if (pos != null) {
        fetchedStops.add(LatLng(pos.latitude, pos.longitude)); 
      } else {
        fetchedStops.add(const LatLng(24.8607, 67.0011)); 
      }

      for (var doc in snap.docs) {
        final data = doc.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          final lat = (data['latitude'] as num).toDouble();
          final lng = (data['longitude'] as num).toDouble();
          if (!lat.isNaN && !lng.isNaN) {
            fetchedStops.add(LatLng(lat, lng));
          }
        }
      }

      if (mounted) {
        setState(() {
          _stops = fetchedStops;
          _isLoadingMap = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMap = false);
    }
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371; // km
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;
    final aLat = a.latitude * pi / 180;
    final bLat = b.latitude * pi / 180;

    final x = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(aLat) * cos(bLat);
    final y = 2 * atan2(sqrt(x), sqrt(1 - x));
    return earthRadius * y;
  }

  void _runTSPOptimization() async {
    if (_stops.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active campaigns found with location data to optimize.')),
        );
      }
      return;
    }
    
    setState(() => _isOptimizing = true);
    // Simulate complex calculation for UX
    await Future.delayed(const Duration(seconds: 1));

    // Nearest Neighbor Heuristic
    List<LatLng> unvisited = List.from(_stops);
    List<LatLng> route = [];
    LatLng current = unvisited.removeAt(0); // Start at Depot
    route.add(current);

    double distance = 0;
    while (unvisited.isNotEmpty) {
      LatLng nearest = unvisited[0];
      double minDist = _calculateDistance(current, nearest);

      for (var point in unvisited) {
        double d = _calculateDistance(current, point);
        if (d < minDist) {
          minDist = d;
          nearest = point;
        }
      }

      distance += minDist;
      route.add(nearest);
      unvisited.remove(nearest);
      current = nearest;
    }

    // Return to depot
    distance += _calculateDistance(current, route[0]);
    route.add(route[0]);

    setState(() {
      _optimizedRoute = route;
      _totalDistance = distance;
      _isOptimizing = false;
    });

    // Auto zoom map to fit all route points
    if (route.isNotEmpty && mounted) {
      final bounds = LatLngBounds.fromPoints(route);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50.0),
        ),
      );
    }
  }

  Future<void> _openInGoogleMaps() async {
    if (_optimizedRoute.length < 2) return;
    final origin = _optimizedRoute.first;
    final dest = _optimizedRoute.last;
    final waypoints = _optimizedRoute.sublist(1, _optimizedRoute.length - 1).map((p) => '${p.latitude},${p.longitude}').join('|');
    
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${dest.latitude},${dest.longitude}&waypoints=$waypoints');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Google Maps.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Route Optimization'),
        actions: [
          if (!_isOptimizing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _optimizedRoute = [];
                  _totalDistance = 0.0;
                });
              },
            )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.route, color: AppColors.primary, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Traveling Salesman Problem (TSP)', style: AppTextStyles.titleMedium()),
                          Text(
                            _optimizedRoute.isEmpty
                                ? 'Optimize the delivery route for ${max(0, _stops.length - 1)} stops.'
                                : 'Optimized Distance: ${_totalDistance.toStringAsFixed(2)} km',
                            style: AppTextStyles.bodyMedium(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_optimizedRoute.isNotEmpty)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: const Text('Google Maps', style: TextStyle(color: Colors.white)),
                        onPressed: _openInGoogleMaps,
                      ),
                    ElevatedButton.icon(
                      icon: _isOptimizing
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.play_arrow),
                      label: Text(_isOptimizing ? 'Calculating...' : 'Optimize'),
                      onPressed: _isOptimizing ? null : _runTSPOptimization,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _stops.isNotEmpty ? _stops[0] : const LatLng(30.3753, 69.3451),
                initialZoom: _stops.isNotEmpty ? 13.0 : 5.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.hras.volunteer',
                ),
                if (_optimizedRoute.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _optimizedRoute,
                        strokeWidth: 4.0,
                        color: Colors.blueAccent,
                        pattern: StrokePattern.dashed(segments: [10, 10]),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _stops.asMap().entries.map((entry) {
                    int idx = entry.key;
                    LatLng point = entry.value;
                    bool isDepot = idx == 0;
                    return Marker(
                      point: point,
                      child: CircleAvatar(
                        backgroundColor: isDepot ? Colors.red : Colors.green,
                        child: Text(
                          isDepot ? 'D' : '$idx',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final firestore = FirebaseFirestore.instance;
          await firestore.collection('campaigns').add({
            'title': 'Test Flood Relief',
            'description': 'Test campaign 1',
            'latitude': 24.88,
            'longitude': 67.03,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
          });
          await firestore.collection('campaigns').add({
            'title': 'Test Medical Camp',
            'description': 'Test campaign 2',
            'latitude': 24.84,
            'longitude': 67.08,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
          });
          await firestore.collection('campaigns').add({
            'title': 'Test Food Distribution',
            'description': 'Test campaign 3',
            'latitude': 24.81,
            'longitude': 67.02,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('3 Fake Campaigns Added!')));
            _fetchCampaignLocations();
          }
        },
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Add 3 Fake Campaigns', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
