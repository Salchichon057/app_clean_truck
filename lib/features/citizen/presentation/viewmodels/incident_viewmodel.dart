import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/incident.dart';
import '../../domain/repositories/incident_repository.dart';

class IncidentState {
  final List<Incident> incidents;
  final bool isLoading;
  final String? error;

  IncidentState({
    this.incidents = const [],
    this.isLoading = false,
    this.error,
  });

  IncidentState copyWith({
    List<Incident>? incidents,
    bool? isLoading,
    String? error,
  }) {
    return IncidentState(
      incidents: incidents ?? this.incidents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class IncidentViewModel extends StateNotifier<IncidentState> {
  final IncidentRepository _repository;

  IncidentViewModel(this._repository) : super(IncidentState());

  Future<void> loadIncidents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final incidents = await _repository.getAllIncidents();
      state = state.copyWith(incidents: incidents, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadIncidentsByUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final incidents = await _repository.getIncidentsByUser(userId);
      state = state.copyWith(incidents: incidents, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addIncident(Incident incident) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addIncident(incident);
      await loadIncidents();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateIncident(Incident incident) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateIncident(incident);
      await loadIncidents();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteIncident(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteIncident(id);
      await loadIncidents();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
