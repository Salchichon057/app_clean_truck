import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/truck.dart';
import '../../domain/repositories/truck_repository.dart';

class TruckState {
  final List<Truck> trucks;
  final bool isLoading;
  final String? error;

  TruckState({this.trucks = const [], this.isLoading = false, this.error});

  TruckState copyWith({List<Truck>? trucks, bool? isLoading, String? error}) {
    return TruckState(
      trucks: trucks ?? this.trucks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TruckViewModel extends StateNotifier<TruckState> {
  final TruckRepository _repository;

  TruckViewModel(this._repository) : super(TruckState());

  Future<void> loadTrucks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final trucks = await _repository.getAllTrucks();
      state = state.copyWith(trucks: trucks, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addTruck(Truck truck) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addTruck(truck);
      await loadTrucks();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateTruck(Truck truck) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateTruck(truck);
      await loadTrucks();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteTruck(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteTruck(id);
      await loadTrucks();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
