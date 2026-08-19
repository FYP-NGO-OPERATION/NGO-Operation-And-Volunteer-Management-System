import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import 'campaign_detail_screen.dart';
import 'package:intl/intl.dart';
import '../../services/location_service.dart';

class CampaignMapScreen extends StatefulWidget {
  const CampaignMapScreen({super.key});

  @override
  State<CampaignMapScreen> createState() => _CampaignMapScreenState();
}

class _CampaignMapScreenState extends State<CampaignMapScreen> {
  final CampaignService _campaignService = CampaignService();
  final MapController _mapController = MapController();

  // Multan, Pakistan (Default Center for HRAS)
  LatLng _currentCenter = const LatLng(30.1984, 71.4687);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null && mounted) {
      setState(() {
        _currentCenter = LatLng(pos.latitude, pos.longitude);
      });
      // Move map if it is already built
      try {
        _mapController.move(_currentCenter, 13.0);
      } catch (e) {
        // ignore
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get real device location. Showing default map.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ngoId = authProvider.user?.currentNgoId ?? 'HRAS_DEFAULT_ID';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Campaign Map'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _initLocation();
            },
          )
        ],
      ),
      body: StreamBuilder<List<CampaignModel>>(
        stream: _campaignService.getCampaignsStream(ngoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCampaigns = snapshot.data ?? [];
          // Filter campaigns that have valid coordinates
          final mappedCampaigns = allCampaigns.where((c) => 
            c.latitude != null && 
            c.longitude != null && 
            !c.latitude!.isNaN && 
            !c.longitude!.isNaN
          ).toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 12.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ngo_volunteer_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentCenter,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                  ),
                  ...mappedCampaigns.map((campaign) {
                  return Marker(
                    point: LatLng(campaign.latitude!, campaign.longitude!),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => _showCampaignDetails(context, campaign),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  );
                }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCampaignDetails(BuildContext context, CampaignModel campaign) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      campaign.status.name.toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(campaign.location, style: const TextStyle(color: Colors.grey))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(campaign.startDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CampaignDetailScreen(campaign: campaign),
                      ),
                    );
                  },
                  child: const Text('View Campaign Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
