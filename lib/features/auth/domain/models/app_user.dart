import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String dni;
  final String role;
  final Location location;
  final String status;
  final Timestamp createdAt;
  final NotificationPreferences notificationPreferences;
  final String? fcmToken; // Token FCM para notificaciones push
  final String? selectedRouteId; // ID de la ruta seleccionada (para ciudadanos)

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dni,
    required this.role,
    required this.location,
    required this.status,
    required this.createdAt,
    required this.notificationPreferences,
    this.fcmToken,
    this.selectedRouteId,
  });

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? dni,
    String? role,
    Location? location,
    String? status,
    Timestamp? createdAt,
    NotificationPreferences? notificationPreferences,
    String? fcmToken,
    String? selectedRouteId,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dni: dni ?? this.dni,
      role: role ?? this.role,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      fcmToken: fcmToken ?? this.fcmToken,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dni': dni,
      'role': role,
      'location': location.toJson(),
      'status': status,
      'createdAt': createdAt,
      'notificationPreferences': {
        'daytimeAlerts': notificationPreferences.daytimeAlerts,
        'nighttimeAlerts': notificationPreferences.nighttimeAlerts,
        'daytimeStart': notificationPreferences.daytimeStart,
        'daytimeEnd': notificationPreferences.daytimeEnd,
        'nighttimeStart': notificationPreferences.nighttimeStart,
        'nighttimeEnd': notificationPreferences.nighttimeEnd,
      },
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (selectedRouteId != null) 'selectedRouteId': selectedRouteId,
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      dni: data['dni'] ?? '',
      role: data['role'] ?? '',
      location: Location.fromJson(data['location'] ?? {}),
      status: data['status'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      notificationPreferences: NotificationPreferences(
        daytimeAlerts: data['notificationPreferences']?['daytimeAlerts'] ?? true,
        nighttimeAlerts: data['notificationPreferences']?['nighttimeAlerts'] ?? false,
        daytimeStart: data['notificationPreferences']?['daytimeStart'] ?? '06:00',
        daytimeEnd: data['notificationPreferences']?['daytimeEnd'] ?? '22:00',
        nighttimeStart: data['notificationPreferences']?['nighttimeStart'] ?? '22:00',
        nighttimeEnd: data['notificationPreferences']?['nighttimeEnd'] ?? '06:00',
      ),
      fcmToken: data['fcmToken'],
      selectedRouteId: data['selectedRouteId'],
    );
  }
}
