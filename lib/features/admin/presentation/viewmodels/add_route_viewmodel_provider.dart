import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/admin/domain/models/route.dart';
import 'package:comaslimpio/features/admin/infrastructure/mappers/route_mapper.dart';

class AddRouteState {
  final bool isLoading;
  final String? error;
  final bool success;

  AddRouteState({this.isLoading = false, this.error, this.success = false});

  AddRouteState copyWith({bool? isLoading, String? error, bool? success}) {
    return AddRouteState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class AddRouteViewModel extends StateNotifier<AddRouteState> {
  final FirestoreService firestoreService;

  AddRouteViewModel(this.firestoreService) : super(AddRouteState());

  Future<void> addRoute(Route route) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      await firestoreService.addDocument('routes', RouteMapper.toJson(route));
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final addRouteViewModelProvider =
    StateNotifierProvider<AddRouteViewModel, AddRouteState>((ref) {
      final firestoreService = ref.watch(firestoreServiceProvider);
      return AddRouteViewModel(firestoreService);
    });
