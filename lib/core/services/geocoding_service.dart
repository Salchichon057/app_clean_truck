import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<String> getAddressFromLatLng(
    double lat,
    double lng,
    String mapboxToken,
  ) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json?access_token=$mapboxToken&language=es';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        return data['features'][0]['place_name'];
      }
    }
    return 'Dirección no encontrada';
  }
}
