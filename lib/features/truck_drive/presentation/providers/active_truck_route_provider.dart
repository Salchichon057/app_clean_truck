import 'package:comaslimpio/features/admin/domain/models/route.dart'
    as my_route;
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_on_map_provider.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/admin/presentation/providers/route_provider.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

final activeTruckRouteProvider = FutureProvider<my_route.Route?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final truckRepo = ref.watch(truckRepositoryProvider);
  final trucks = await truckRepo.getTrucksByUser(user.uid);

  if (trucks.isEmpty) return null;
  final truck = trucks.first;

  final routeRepo = ref.watch(routeRepositoryProvider);
  final routes = await routeRepo.watchAllRoutes().first;

  final myRoute = routes.firstWhereOrNull(
    (r) =>
        r.idTruck.trim().toLowerCase() == truck.idTruck.trim().toLowerCase() &&
        r.status == 'active',
  );
  return myRoute;
});
