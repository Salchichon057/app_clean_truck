import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';

class Incident {
  final String uid;
  final String idAppUsers;
  final String description;
  final Location location;
  final String status;
  final Timestamp date;

  Incident({
    required this.uid,
    required this.idAppUsers,
    required this.description,
    required this.location,
    required this.status,
    required this.date,
  });

  Incident copyWith({
    String? uid,
    String? idAppUsers,
    String? description,
    Location? location,
    String? status,
    Timestamp? date,
  }) {
    return Incident(
      uid: uid ?? this.uid,
      idAppUsers: idAppUsers ?? this.idAppUsers,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}
