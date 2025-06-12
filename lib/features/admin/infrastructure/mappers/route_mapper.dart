import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/admin/domain/models/route.dart';

class RouteMapper {
  static Route fromJson(Map<String, dynamic> json) {
    return Route(
      uid: json['uid'],
      idTruckDrivers: json['id_truck_drivers'],
      points: (json['points'] as List<dynamic>)
          .map((point) => Location.fromJson(point))
          .toList(),
      status: json['status'],
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toJson(Route route) {
    return {
      'uid': route.uid,
      'id_truck_drivers': route.idTruckDrivers,
      'points': route.points.map((point) => point.toJson()).toList(),
      'status': route.status,
      'date': route.date,
    };
  }
}
