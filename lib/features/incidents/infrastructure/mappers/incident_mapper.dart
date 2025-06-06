import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/incidents/domain/models/incident.dart';

class IncidentMapper {
  static Incident fromJson(Map<String, dynamic> json) {
    return Incident(
      uid: json['uid'],
      idAppUsers: json['id_users'],
      description: json['description'],
      location: Location.fromJson(json['location']),
      status: json['status'],
      date: (json['date'] as Timestamp),
    );
  }

  static Map<String, dynamic> toJson(Incident incident) {
    return {
      'uid': incident.uid,
      'id_users': incident.idAppUsers,
      'description': incident.description,
      'location': incident.location.toJson(),
      'status': incident.status,
      'date': incident.date,
    };
  }
}
