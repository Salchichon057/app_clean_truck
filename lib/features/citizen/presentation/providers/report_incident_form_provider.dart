import 'package:comaslimpio/core/inputs/description.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/incident_provider.dart';
import 'package:comaslimpio/features/citizen/presentation/viewmodels/incident_form_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportIncidentFormState {
  final Description description;
  final Location? incidentLocation;
  final bool isValid;
  final bool isSubmitting;
  final String? errorMessage;

  ReportIncidentFormState({
    this.description = const Description.pure(),
    this.incidentLocation,
    this.isValid = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  ReportIncidentFormState copyWith({
    Description? description,
    Location? incidentLocation,
    bool? isValid,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ReportIncidentFormState(
      description: description ?? this.description,
      incidentLocation: incidentLocation ?? this.incidentLocation,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class ReportIncidentFormNotifier
    extends StateNotifier<ReportIncidentFormState> {
  ReportIncidentFormNotifier() : super(ReportIncidentFormState());

  void updateDescription(String value) {
    final description = Description.dirty(value);
    state = state.copyWith(
      description: description,
      isValid: _isFormValid(description: description),
    );
  }

  void updateIncidentLocation(Location location) {
    state = state.copyWith(
      incidentLocation: location,
      isValid: _isFormValid(incidentLocation: location),
    );
  }

  bool _isFormValid({Description? description, Location? incidentLocation}) {
    final d = description ?? state.description;
    final l = incidentLocation ?? state.incidentLocation;
    return d.isValid && l != null;
  }

  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}

final reportIncidentFormProvider =
    StateNotifierProvider.autoDispose<
      ReportIncidentFormNotifier,
      ReportIncidentFormState
    >((ref) {
      return ReportIncidentFormNotifier();
    });

final reportIncidentViewModelProvider =
    StateNotifierProvider.autoDispose<
      ReportIncidentViewModel,
      AsyncValue<void>
    >((ref) {
      final incidentRepository = ref.watch(incidentRepositoryProvider);
      return ReportIncidentViewModel(incidentRepository, ref);
    });
