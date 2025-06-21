import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck_driver.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';
import 'package:comaslimpio/features/truck_drive/infrastructure/mappers/truck_driver_mapper.dart';

// Modelo enriquecido para la UI
class TruckDriverListItem {
  final String name;
  final String dni;
  final String email;
  final String phoneNumber;
  final String status; // available/unavailable
  final String? truckId; // null si no tiene camión asignado

  TruckDriverListItem({
    required this.name,
    required this.dni,
    required this.email,
    required this.phoneNumber,
    required this.status,
    this.truckId,
  });
}

final truckDriverListProvider = StreamProvider<List<TruckDriverListItem>>((
  ref,
) {
  final firestore = FirebaseFirestore.instance;

  // Usuarios con rol truck_driver
  final usersStream = firestore
      .collection('app_users')
      .where('role', isEqualTo: 'truck_driver')
      .snapshots()
      .map((snapshot) {
        final users = snapshot.docs
            .map((doc) {
              try {
                final user = AppUserMapper.fromJson(doc.data());
                return user;
              } catch (e) {
                // print('Error al mapear AppUser: $e');
                return null;
              }
            })
            .whereType<AppUser>()
            .toList();
        // print('Usuarios truck_driver cargados: ${users.length}');
        return users;
      });

  // Relación truck_drivers (asignación de camión)
  final truckDriversStream = firestore
      .collection('truck_drivers')
      .snapshots()
      .map((snapshot) {
        final drivers = snapshot.docs
            .map((doc) {
              try {
                final driver = TruckDriverMapper.fromJson(doc.data());
                return driver;
              } catch (e) {
                // print('Error al mapear TruckDriver: $e');
                return null;
              }
            })
            .whereType<TruckDriver>()
            .toList();
        // print('Asignaciones truck_drivers cargadas: ${drivers.length}');
        return drivers;
      });

  return Rx.combineLatest2<
    List<AppUser>,
    List<TruckDriver>,
    List<TruckDriverListItem>
  >(usersStream, truckDriversStream, (users, truckDrivers) {
    // print('Combinando usuarios y asignaciones...');
    final items = users.map((user) {
      // Busca si tiene camión asignado
      final driver = truckDrivers.where((d) => d.uidUsers == user.uid).toList();
      if (driver.isNotEmpty) {
        // print(
        //   'Usuario ${user.name ?? user.uid} tiene camión asignado: ${driver.first.idTruck}',
        // );
        return TruckDriverListItem(
          name: user.name,
          dni: user.dni,
          email: user.email,
          phoneNumber: user.phoneNumber,
          status: 'unavailable',
          truckId: driver.first.idTruck,
        );
      } else {
        // print('Usuario ${user.name ?? user.uid} está disponible');
        return TruckDriverListItem(
          name: user.name,
          dni: user.dni,
          email: user.email,
          phoneNumber: user.phoneNumber,
          status: 'available',
          truckId: null,
        );
      }
    }).toList();
    // print('Total items para UI: ${items.length}');
    return items;
  });
});
