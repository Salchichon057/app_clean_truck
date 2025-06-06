import 'package:comaslimpio/core/models/location.dart';

class Route {
  final String uid;
  final String idTruckDrivers;
  final List<Location> points;
  final String status;
  final DateTime date;

  Route({
    required this.uid,
    required this.idTruckDrivers,
    required this.points,
    required this.status,
    required this.date,
  });
}
