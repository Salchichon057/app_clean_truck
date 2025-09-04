import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: ".env");
  }

  static String apiUrl = dotenv.env['NOTIFICATION_API_URL'] ?? 'http://localhost:3000';
}
