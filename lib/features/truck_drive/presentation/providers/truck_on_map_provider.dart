import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck_driver.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck_on_map.dart';
import 'package:rxdart/rxdart.dart';
import 'truck_provider.dart';
import 'truck_drivers_provider.dart';

// Extensión para firstWhereOrNull
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

final trucksOnMapStreamProvider = StreamProvider<List<TruckOnMap>>((ref) {
  // Usa los repositorios directamente para obtener los streams puros
  final truckRepo = ref.watch(truckRepositoryProvider);
  final truckDriverRepo = ref.watch(truckDriverRepositoryProvider);

  final trucksStream = truckRepo.watchAllTrucks();
  final truckDriversStream = truckDriverRepo.watchAllTruckDrivers();

  // Usuarios conductores activos
  final firestore = FirebaseFirestore.instance;
  final appUsersStream = firestore
      .collection('app_users')
      .where('role', isEqualTo: 'truck_driver')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AppUserMapper.fromJson(doc.data()))
            .toList(),
      );

  // Combina los tres streams
  return Rx.combineLatest3<
    List<Truck>,
    List<TruckDriver>,
    List<AppUser>,
    List<TruckOnMap>
  >(trucksStream, truckDriversStream, appUsersStream, (
    trucks,
    truckDrivers,
    appUsers,
  ) {
    final result = <TruckOnMap>[];
    for (final driver in truckDrivers) {
      final truck = trucks.firstWhereOrNull((t) => t.idTruck == driver.idTruck);
      final user = appUsers.firstWhereOrNull((u) => u.uid == driver.uidUsers);
      if (truck != null && user != null) {
        result.add(
          TruckOnMap(truck: truck, truckDriver: driver, driverUser: user),
        );
      }
    }
    return result;
  });
});
