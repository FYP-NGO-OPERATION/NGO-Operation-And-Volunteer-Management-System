import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchCampaignLocations();
  }

  Future<void> _fetchCampaignLocations() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('campaigns').where('status', isEqualTo: 'active').get();
      List<LatLng> fetchedStops = [];
      
      // Default Depot (e.g., NGO Headquarters)
      fetchedStops.add(const LatLng(24.8607, 67.0011)); 

      for (var doc in snap.docs) {
        final data = doc.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          fetchedStops.add(LatLng((data['latitude'] as num).toDouble(), (data['longitude'] as num).toDouble()));
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
    if (_stops.length < 2) return;
    
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
            child: Row(
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
                            ? 'Optimize the delivery route for 4 stops.'
                            : 'Optimized Distance: ${_totalDistance.toStringAsFixed(2)} km',
                        style: AppTextStyles.bodyMedium(color: Colors.blueGrey),
                      ),
                    ],
                  ),
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
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(24.8607, 67.0511),
                initialZoom: 11.5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
    );
  }
}
