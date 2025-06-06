class NotificationPreferences {
  final bool daytimeAlerts;
  final bool nighttimeAlerts;
  final String daytimeStart;
  final String daytimeEnd;
  final String nighttimeStart;
  final String nighttimeEnd;

  NotificationPreferences({
    required this.daytimeAlerts,
    required this.nighttimeAlerts,
    required this.daytimeStart,
    required this.daytimeEnd,
    required this.nighttimeStart,
    required this.nighttimeEnd,
  });

  NotificationPreferences copyWith({
    bool? daytimeAlerts,
    bool? nighttimeAlerts,
    String? daytimeStart,
    String? daytimeEnd,
    String? nighttimeStart,
    String? nighttimeEnd,
  }) {
    return NotificationPreferences(
      daytimeAlerts: daytimeAlerts ?? this.daytimeAlerts,
      nighttimeAlerts: nighttimeAlerts ?? this.nighttimeAlerts,
      daytimeStart: daytimeStart ?? this.daytimeStart,
      daytimeEnd: daytimeEnd ?? this.daytimeEnd,
      nighttimeStart: nighttimeStart ?? this.nighttimeStart,
      nighttimeEnd: nighttimeEnd ?? this.nighttimeEnd,
    );
  }
}
