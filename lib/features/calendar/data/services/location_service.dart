import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationSuggestion {
  final String displayName;
  final String lat;
  final String lon;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: json['lat'] ?? '',
      lon: json['lon'] ?? '',
    );
  }
}

class LocationService {
  // Menggunakan API Nominatim OpenStreetMap
  Future<List<LocationSuggestion>> searchLocation(String query) async {
    if (query.length < 3) return [];

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'MindlyApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) => LocationSuggestion.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}