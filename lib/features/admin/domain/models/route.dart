import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';

class Route {
  final String uid;
  final String idTruck;
  final String routeName;
  final List<Location> points;
  final String status;
  final Timestamp date;

  Route({
    required this.uid,
    required this.idTruck,
    required this.routeName,
    required this.points,
    required this.status,
    required this.date,
  });

  Route copyWith({
    String? uid,
    String? idTruck,
    String? routeName,
    List<Location>? points,
    String? status,
    Timestamp? date,
  }) {
    return Route(
      uid: uid ?? this.uid,
      idTruck: idTruck ?? this.idTruck,
      routeName: routeName ?? this.routeName,
      points: points ?? this.points,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}
