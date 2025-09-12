import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      throw Exception('Failed to load environment variables. Make sure .env file exists.');
    }
  }

  static String get apiUrl {
    final url = dotenv.env['NOTIFICATION_API_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('NOTIFICATION_API_URL not found in .env file');
    }
    return url;
  }
}
