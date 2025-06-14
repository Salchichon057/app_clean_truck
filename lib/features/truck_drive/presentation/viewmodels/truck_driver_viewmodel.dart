import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/truck_driver.dart';
import '../../domain/repositories/truck_driver_repository.dart';

class TruckDriverState {
  final List<TruckDriver> truckDrivers;
  final bool isLoading;
  final String? error;

  TruckDriverState({
    this.truckDrivers = const [],
    this.isLoading = false,
    this.error,
  });

  TruckDriverState copyWith({
    List<TruckDriver>? truckDrivers,
    bool? isLoading,
    String? error,
  }) {
    return TruckDriverState(
      truckDrivers: truckDrivers ?? this.truckDrivers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TruckDriverViewModel extends StateNotifier<TruckDriverState> {
  final TruckDriverRepository _repository;

  TruckDriverViewModel(this._repository) : super(TruckDriverState());

  Future<void> loadTruckDrivers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final drivers = await _repository.getAllTruckDrivers();
      state = state.copyWith(truckDrivers: drivers, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addTruckDriver(TruckDriver driver) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addTruckDriver(driver);
      await loadTruckDrivers();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateTruckDriver(TruckDriver driver) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateTruckDriver(driver);
      await loadTruckDrivers();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteTruckDriver(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteTruckDriver(id);
      await loadTruckDrivers();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
