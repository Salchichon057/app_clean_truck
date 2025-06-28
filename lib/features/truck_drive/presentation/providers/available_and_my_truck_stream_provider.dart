import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:rxdart/rxdart.dart';

final availableAndMyTruckStreamProvider = StreamProvider<List<Truck>>((ref) {
  final truckRepo = ref.watch(truckRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  final availableStream = truckRepo.watchTrucksByStatus('available');
  final myTruckStream = user == null
      ? Stream.value(<Truck>[])
      : truckRepo.watchTrucksByUser(user.uid);

  return Rx.combineLatest2<List<Truck>, List<Truck>, List<Truck>>(
    availableStream,
    myTruckStream,
    (available, mine) {
      final all = [...available, ...mine];
      final unique = <String, Truck>{};
      for (final t in all) {
        unique[t.idTruck] = t;
      }
      return unique.values.toList();
    },
  );
});
