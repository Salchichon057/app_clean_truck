import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:comaslimpio/features/admin/domain/models/route.dart'
    as my_route;
import 'package:comaslimpio/features/admin/infrastructure/mappers/route_local_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

final selectedRouteProvider =
    StateNotifierProvider<SelectedRouteNotifier, my_route.Route?>((ref) {
      return SelectedRouteNotifier(ref);
    });

class SelectedRouteNotifier extends StateNotifier<my_route.Route?> {
  final Ref ref;
  SelectedRouteNotifier(this.ref) : super(null) {
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final routeJson = prefs.getString('selected_route');
    if (routeJson != null) {
      state = RouteLocalMapper.fromJson(jsonDecode(routeJson));
    }
  }

  Future<void> setRoute(my_route.Route? route) async {
    final prefs = await SharedPreferences.getInstance();
    final user = ref.read(currentUserProvider);

    if (route == null) {
      await prefs.remove('selected_route');
      state = null;
      // Limpia también en Firestore si quieres
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('app_users')
            .doc(user.uid)
            .update({'selectedRouteId': null});
      }
    } else {
      await prefs.setString(
        'selected_route',
        jsonEncode(RouteLocalMapper.toJson(route)),
      );
      state = route;
      // Guarda en Firestore el id de la ruta seleccionada
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('app_users')
            .doc(user.uid)
            .update({'selectedRouteId': route.uid});
      }
    }
  }
}
