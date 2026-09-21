import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherWarningCard extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherWarningCard({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherWarningCard> createState() => _WeatherWarningCardState();
}

class _WeatherWarningCardState extends State<WeatherWarningCard> {
  bool _isLoading = true;
  bool _hasHazard = false;
  String _warningMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Free Open-Meteo API (no key required)
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${widget.latitude}&longitude=${widget.longitude}&current_weather=true&daily=precipitation_sum,temperature_2m_max&timezone=auto',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currentTemp = data['current_weather']['temperature'] as double;
        final isRaining =
            data['current_weather']['weathercode'] >=
            50; // WMO codes >= 50 indicate rain/snow/storm

        if (isRaining) {
          _hasHazard = true;
          _warningMessage =
              'Heavy precipitation detected in the campaign area. Please bring rain gear.';
        } else if (currentTemp > 38.0) {
          _hasHazard = true;
          _warningMessage =
              'Extreme heat alert ($currentTemp°C). Please carry extra water and stay hydrated.';
        } else if (currentTemp < 5.0) {
          _hasHazard = true;
          _warningMessage =
              'Extreme cold alert ($currentTemp°C). Wear warm clothes and carry thermal blankets.';
        }
      }
    } catch (e) {
      // Fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink(); // Don't show while loading
    if (!_hasHazard) return const SizedBox.shrink(); // Hide if safe

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
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Weather Hazard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _warningMessage,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
