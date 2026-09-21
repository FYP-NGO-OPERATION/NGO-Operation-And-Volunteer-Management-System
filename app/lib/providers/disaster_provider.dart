import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DisasterProvider with ChangeNotifier {
  bool _isEmergencyMode = false;

  bool get isEmergencyMode => _isEmergencyMode;

  void toggleEmergencyMode() {
    _isEmergencyMode = !_isEmergencyMode;
    notifyListeners();
  }

  /// Calculates shortest path using Open Source Routing Machine (OSRM)
  Future<List<LatLng>> getOptimizedRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;
          return coordinates
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching OSRM route: $e');
    }
    return [];
  }
}
