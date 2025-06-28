import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/admin/domain/models/route.dart';

class RouteLocalMapper {
  static Map<String, dynamic> toJson(Route route) {
    return {
      'uid': route.uid,
      'id_truck': route.idTruck,
      'route_name': route.routeName,
      'points': route.points.map((point) => point.toJson()).toList(),
      'status': route.status,
      'date': route.date.millisecondsSinceEpoch,
    };
  }

  static Route fromJson(Map<String, dynamic> json) {
    return Route(
      uid: json['uid'],
      idTruck: json['id_truck'],
      routeName: json['route_name'] ?? '',
      points: (json['points'] as List)
          .map((point) => Location.fromJson(point))
          .toList(),
      status: json['status'],
      date: Timestamp.fromMillisecondsSinceEpoch(json['date']),
    );
  }
}
