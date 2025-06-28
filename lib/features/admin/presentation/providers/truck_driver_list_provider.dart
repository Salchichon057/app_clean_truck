import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_on_map_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TruckDriverListItem {
  final String uid;
  final String name;
  final String dni;
  final String email;
  final String phoneNumber;
  final String status; // available|unavailable
  final String? truckId; // null si no tiene camión asignado

  TruckDriverListItem({
    required this.uid,
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
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return TruckDriverListItem(
            uid: doc.id,
            name: data['name'] ?? '',
            dni: data['dni'] ?? '',
            email: data['email'] ?? '',
            phoneNumber: data['phone_number'] ?? '',
            status: 'available',
            truckId: null,
          );
        }).toList();
      });

  return usersStream.asyncMap((users) async {
    final trucksSnapshot = await firestore.collection('trucks').get();
    final trucks = trucksSnapshot.docs.map((doc) => doc.data()).toList();

    return users.map((user) {
      final assignedTruck = trucks.firstWhereOrNull(
        (truck) => truck['id_app_user'] == user.uid,
      );
      return TruckDriverListItem(
        uid: user.uid,
        name: user.name,
        dni: user.dni,
        email: user.email,
        phoneNumber: user.phoneNumber,
        status: assignedTruck == null ? 'available' : 'unavailable',
        truckId: assignedTruck?['id_truck'],
      );
    }).toList();
  });
});
