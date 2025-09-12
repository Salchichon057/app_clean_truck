import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapToken {
  static Future<String> getMapToken() async {
    try {
      await dotenv.load(fileName: ".env");
      final token = dotenv.env['MAP_API_TOKEN'];
      if (token == null || token.isEmpty) {
        throw Exception('MAP_API_TOKEN not found in .env file');
      }
      return token;
    } catch (e) {
      print('Error loading MAP_API_TOKEN: $e');
      return 'No token found';
    }
  }
}
