import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_on_map_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';

final truckByDriverProvider = FutureProvider.family<Truck?, String>((
  ref,
  driverId,
) async {
  final trucks = await ref.watch(trucksStreamProvider.future);
  return trucks.firstWhereOrNull(
    (truck) => truck.idAppUser == driverId,
  );
});
