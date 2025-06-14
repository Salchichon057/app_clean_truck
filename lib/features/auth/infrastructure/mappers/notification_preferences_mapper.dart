import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';

class NotificationPreferencesMapper {
  static NotificationPreferences fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      daytimeAlerts: json['daytime_alerts'] ?? false,
      nighttimeAlerts: json['nighttime_alerts'] ?? false,
      daytimeStart: json['daytime_start'] ?? '06:00',
      daytimeEnd: json['daytime_end'] ?? '20:00',
      nighttimeStart: json['nighttime_start'] ?? '20:00',
      nighttimeEnd: json['nighttime_end'] ?? '06:00',
    );
  }

  static Map<String, dynamic> toJson(NotificationPreferences preferences) {
    return {
      'daytime_alerts': preferences.daytimeAlerts,
      'nighttime_alerts': preferences.nighttimeAlerts,
      'daytime_start': preferences.daytimeStart,
      'daytime_end': preferences.daytimeEnd,
      'nighttime_start': preferences.nighttimeStart,
      'nighttime_end': preferences.nighttimeEnd,
    };
  }
}
