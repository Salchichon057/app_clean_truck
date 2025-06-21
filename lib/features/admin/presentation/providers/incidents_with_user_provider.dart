// ignore_for_file: unused_local_variable

import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:comaslimpio/features/citizen/domain/models/incident.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';
import 'package:comaslimpio/features/citizen/infrastructure/mappers/incident_mapper.dart';

class IncidentWithUser {
  final Incident incident;
  final String? userName;

  IncidentWithUser({required this.incident, required this.userName});
}

final incidentsWithUserProvider = StreamProvider<List<IncidentWithUser>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);

  // Stream de incidentes ORDENADOS por fecha
  final incidentsStream = firestoreService.streamCollection('incidents').map((
    snapshot,
  ) {
    final list = snapshot.docs
        .map(
          (doc) => IncidentMapper.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // Más recientes primero
    // print('Incidents loaded: ${list.length}');
    for (final inc in list) {
      // print('Incident: ${inc.idAppUsers} - ${inc.description}');
    }
    return list;
  });

  // Stream de usuarios
  final usersStream = firestoreService
      .streamCollection('app_users')
      .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                final user = AppUserMapper.fromJson(
                  doc.data() as Map<String, dynamic>,
                );
                return user;
              } catch (e) {
                return null;
              }
            })
            .whereType<AppUser>()
            .toList();
      })
      .map((users) {
        for (final user in users) {}
        return users;
      });

  // Join manual
  return Rx.combineLatest2<
    List<Incident>,
    List<AppUser>,
    List<IncidentWithUser>
  >(incidentsStream, usersStream, (incidents, users) {
    // print('Combining incidents and users...');
    return incidents.map((incident) {
      final user = users.where((u) => u.uid == incident.idAppUsers).isNotEmpty
          ? users.firstWhere((u) => u.uid == incident.idAppUsers)
          : null;
      final userName = user?.name ?? 'Usuario eliminado';
      // print('Incident "${incident.description}" reported by: $userName');
      return IncidentWithUser(incident: incident, userName: userName);
    }).toList();
  });
});
