import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/disaster_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/incident_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';

class DisasterMapScreen extends StatefulWidget {
  const DisasterMapScreen({super.key});

  @override
  State<DisasterMapScreen> createState() => _DisasterMapScreenState();
}

class _DisasterMapScreenState extends State<DisasterMapScreen> {
  @override
  Widget build(BuildContext context) {
    final disasterProvider = Provider.of<DisasterProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final bool isEmergency = disasterProvider.isEmergencyMode;

    // Center on Pakistan by default
    final initialCenter = const LatLng(30.3753, 69.3451);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            if (isEmergency) const Icon(Icons.warning, color: Colors.white),
            if (isEmergency) const SizedBox(width: 8),
            Text(
              isEmergency ? 'DISASTER RELIEF MODE' : 'Normal Map Mode',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: isEmergency ? AppColors.error : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 300)),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              return FlutterMap(
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 5.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
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
                          child: const Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        Marker(
                          point: const LatLng(24.82, 67.05),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: Colors.green,
                            size: 40,
                          ),
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
                          return Marker(
                            point: LatLng(
                              incident.latitude,
                              incident.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(incident.title),
                                    content: Text(
                                      '${incident.description}\n\nReported by: ${incident.reportedByUserName}',
                                    ),
                                    actions: [
                                      if (user?.isAdmin == true ||
                                          user?.uid ==
                                              incident.reportedByUserId)
                                        TextButton(
                                          onPressed: () {
                                            IncidentService().resolveIncident(
                                              incident.id,
                                            );
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text(
                                            'Mark Resolved',
                                            style: TextStyle(
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      TextButton(
                                        onPressed: () async {
                                          final url = Uri.parse(
                                            'https://www.google.com/maps/dir/?api=1&destination=${incident.latitude},${incident.longitude}',
                                          );
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          } else {
                                            if (ctx.mounted)
                                              SnackbarHelper.showError(
                                                ctx,
                                                'Could not open Google Maps.',
                                              );
                                          }
                                        },
                                        child: const Text(
                                          'Get Directions',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.orange,
                                size: 40,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReportIncidentDialog(context, user),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add_location, color: Colors.white),
        label: const Text(
          'Report Incident',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showReportIncidentDialog(BuildContext context, user) {
    if (user == null) return;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Incident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title (e.g. Flooded Road)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.isEmpty) return;

              try {
                // Get actual device location properly
                bool serviceEnabled =
                    await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  if (ctx.mounted)
                    SnackbarHelper.showError(
                      ctx,
                      'Please enable GPS/Location in your phone settings.',
                    );
                  return;
                }

                LocationPermission permission =
                    await Geolocator.checkPermission();
                if (permission == LocationPermission.denied) {
                  permission = await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) {
                    if (ctx.mounted)
                      SnackbarHelper.showError(
                        ctx,
                        'Location permissions are denied',
                      );
                    return;
                  }
                }

                if (permission == LocationPermission.deniedForever) {
                  if (ctx.mounted)
                    SnackbarHelper.showError(
                      ctx,
                      'Location permissions are permanently denied, we cannot request permissions.',
                    );
                  return;
                }

                if (ctx.mounted)
                  SnackbarHelper.showSuccess(
                    ctx,
                    'Fetching your live location... Please wait.',
                  );

                final pos = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                  timeLimit: const Duration(seconds: 15), // don't hang forever
                );

                final service = IncidentService();
                final incident = IncidentModel(
                  id: service.generateId(),
                  reportedByUserId: user.uid,
                  reportedByUserName: user.name,
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                  reportedAt: DateTime.now(),
                );
                await service.reportIncident(incident);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  SnackbarHelper.showSuccess(
                    ctx,
                    'Incident Reported Successfully!',
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  SnackbarHelper.showError(
                    ctx,
                    'An unexpected error occurred getting location. Please try again.',
                  );
                }
              }
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
