import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:comaslimpio/features/admin/domain/models/route.dart'
    as my_route;
import 'package:comaslimpio/features/admin/infrastructure/mappers/route_local_mapper.dart';

final selectedRouteProvider =
    StateNotifierProvider<SelectedRouteNotifier, my_route.Route?>((ref) {
      return SelectedRouteNotifier();
    });

class SelectedRouteNotifier extends StateNotifier<my_route.Route?> {
  SelectedRouteNotifier() : super(null) {
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
    if (route == null) {
      await prefs.remove('selected_route');
      state = null;
    } else {
      await prefs.setString(
        'selected_route',
        jsonEncode(RouteLocalMapper.toJson(route)),
      );
      state = route;
    }
  }
}
