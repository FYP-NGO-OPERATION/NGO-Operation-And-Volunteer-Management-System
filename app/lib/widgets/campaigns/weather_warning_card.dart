import 'package:flutter/material.dart';

class WeatherWarningCard extends StatelessWidget {
  final bool isHazardous;
  
  const WeatherWarningCard({super.key, this.isHazardous = true});

  @override
  Widget build(BuildContext context) {
    if (!isHazardous) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_sync, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Weather Hazard Warning',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
                SizedBox(height: 4),
                Text(
                  'Heavy rain is expected at the campaign location tomorrow. Please bring raincoats and secure all electronic equipment.',
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
