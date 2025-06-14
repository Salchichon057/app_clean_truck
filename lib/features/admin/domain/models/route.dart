import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';

class Route {
  final String uid;
  final String idTruckDrivers;
  final List<Location> points;
  final String status;
  final Timestamp date;

  Route({
    required this.uid,
    required this.idTruckDrivers,
    required this.points,
    required this.status,
    required this.date,
  });

  Route copyWith({
    String? uid,
    String? idTruckDrivers,
    List<Location>? points,
    String? status,
    Timestamp? date,
  }) {
    return Route(
      uid: uid ?? this.uid,
      idTruckDrivers: idTruckDrivers ?? this.idTruckDrivers,
      points: points ?? this.points,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}
