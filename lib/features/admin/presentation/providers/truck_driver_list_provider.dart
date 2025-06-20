import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck_driver.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/truck_drive/infrastructure/mappers/truck_driver_mapper.dart';
import 'package:comaslimpio/features/truck_drive/infrastructure/mappers/truck_mapper.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';

// Modelo para la lista enriquecida
class TruckDriverListItem {
  final TruckDriver truckDriver;
  final AppUser? user;
  final Truck? truck;

  TruckDriverListItem({
    required this.truckDriver,
    required this.user,
    required this.truck,
  });
}

final truckDriverListProvider = StreamProvider<List<TruckDriverListItem>>((
  ref,
) {
  final firestore = FirebaseFirestore.instance;

  // Stream de truck_drivers
  final truckDriversStream = firestore
      .collection('truck_drivers')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => TruckDriverMapper.fromJson(doc.data()))
            .toList(),
      );

  // Stream de app_users (solo truck_driver)
  final usersStream = firestore
      .collection('app_users')
      .where('role', isEqualTo: 'truck_driver')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AppUserMapper.fromJson(doc.data()))
            .toList(),
      );

  // Stream de trucks
  final trucksStream = firestore
      .collection('trucks')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => TruckMapper.fromJson(doc.data()))
            .toList(),
      );

  // Combina los tres streams
  return Rx.combineLatest3<
    List<TruckDriver>,
    List<AppUser>,
    List<Truck>,
    List<TruckDriverListItem>
  >(truckDriversStream, usersStream, trucksStream, (
    truckDrivers,
    users,
    trucks,
  ) {
    return truckDrivers.map((driver) {
      AppUser? user;
      try {
        user = users.firstWhere((u) => u.uid == driver.uidUsers);
      } catch (_) {
        user = null;
      }

      Truck? truck;
      try {
        truck = trucks.firstWhere((t) => t.idTruck == driver.idTruck);
      } catch (_) {
        truck = null;
      }

      return TruckDriverListItem(truckDriver: driver, user: user, truck: truck);
    }).toList();
  });
});
