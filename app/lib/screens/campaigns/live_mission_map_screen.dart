import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isPickerMode = false;
  bool _isSaving = false;
  bool _isSearching = false;

  List<dynamic> _searchResults = [];
  double? _campaignLat;
  double? _campaignLng;

  @override
  void initState() {
    super.initState();
    _campaignLat = widget.initialLat;
    _campaignLng = widget.initialLng;
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch maps: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'org.hras.ngo_volunteer_app'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _searchResults = data;
        });
        if (data.isEmpty && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Location not found')));
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onSearchResultSelected(Map<String, dynamic> result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    _mapController.move(LatLng(lat, lon), 15);
    setState(() {
      _searchResults = [];
      _searchController.text = result['display_name'] ?? '';
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isSearching = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw Exception('Location permissions are denied');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition();
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter = widget.initialLat != null && widget.initialLng != null
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : const LatLng(31.5204, 74.3587); // Default Lahore

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isPickerMode
              ? 'Set Campaign Venue'
              : 'Live Mission: ${widget.campaignTitle}',
        ),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        actions: [
          if (!_isPickerMode)
            IconButton(
              icon: const Icon(Icons.edit_location_alt),
              tooltip: 'Set Campaign Location',
              onPressed: () {
                setState(() {
                  _isPickerMode = true;
                });
              },
            ),
        ],
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
                width: 90,
                height: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _openGoogleMaps(lat, lng),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isFatigued
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                        child: Text(
                          '${name.split(' ').first}\n(Get Route)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isFatigued
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openGoogleMaps(lat, lng),
                      child: Icon(
                        Icons.person_pin_circle,
                        color: isFatigued ? AppColors.error : AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          }

          if (_campaignLat != null && _campaignLng != null && !_isPickerMode) {
            markers.add(
              Marker(
                point: LatLng(_campaignLat!, _campaignLng!),
                width: 100,
                height: 70,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Campaign Venue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 30,
                    ),
                  ],
                ),
              ),
            );
          }

          // Adjust bounds if we have markers
          if (markers.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final bounds = LatLngBounds.fromPoints(
                markers.map((m) => m.point).toList(),
              );
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(50),
                ),
              );
            });
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.satellite_alt, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        _isPickerMode
                            ? 'Drag map to set venue location'
                            : 'Active Volunteers: ${markers.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Picker Mode Overlay
              if (_isPickerMode) ...[
                // Search Bar and Results
                Positioned(
                  top: 80,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search city, address...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () =>
                                        _searchLocation(_searchController.text),
                                  ),
                          ),
                          onSubmitted: _searchLocation,
                          onChanged: (val) {
                            if (val.isEmpty)
                              setState(() => _searchResults = []);
                          },
                        ),
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (ctx, i) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.place,
                                  color: AppColors.primary,
                                ),
                                title: Text(
                                  result['display_name'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                onTap: () => _onSearchResultSelected(
                                  result as Map<String, dynamic>,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // My Location Button
                Positioned(
                  bottom: 100,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: 'my_location',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: _useCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shadow
                        Container(
                          margin: const EdgeInsets.only(top: 30),
                          width: 12,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: AppColors.error,
                          size: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () =>
                              setState(() => _isPickerMode = false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  setState(() => _isSaving = true);
                                  try {
                                    final center = _mapController.camera.center;
                                    await FirebaseFirestore.instance
                                        .collection('campaigns')
                                        .doc(widget.campaignId)
                                        .update({
                                          'latitude': center.latitude,
                                          'longitude': center.longitude,
                                        });
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Venue location updated!',
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        _campaignLat = center.latitude;
                                        _campaignLng = center.longitude;
                                        _isPickerMode = false;
                                        _isSaving = false;
                                      });
                                    }
                                  } catch (e) {
                                    setState(() => _isSaving = false);
                                    if (mounted)
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                  }
                                },
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Location',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
