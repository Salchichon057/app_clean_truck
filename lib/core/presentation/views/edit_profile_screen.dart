import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/core/presentation/widgets/location_edit_modal.dart';
import 'package:comaslimpio/core/presentation/widgets/location_map_preview.dart';
import 'package:comaslimpio/core/services/geocoding_service.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';
import 'package:comaslimpio/features/auth/presentation/providers/edit_form_provider.dart';
import 'package:comaslimpio/features/auth/presentation/viewmodels/edit_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _dniController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(editProfileFormProvider);
    _nameController = TextEditingController(text: formState.name.value);
    _dniController = TextEditingController(text: formState.dni.value);
    _phoneController = TextEditingController(text: formState.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _showLocationEditModal(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final formState = ref.read(editProfileFormProvider);
    final notifier = ref.read(editProfileFormProvider.notifier);

    final result = await showDialog<Location>(
      context: context,
      builder: (context) =>
          LocationEditModal(initialLocation: formState.location),
    );

    if (result != null) {
      notifier.updateLocation(result);
      _updateAddressFromLocation(result, ref);
    }
  }

  Future<void> _updateAddressFromLocation(
    Location location,
    WidgetRef ref,
  ) async {
    try {
      final mapboxToken = await MapToken.getMapToken();
      final address = await GeocodingService.getAddressFromLatLng(
        location.lat,
        location.long,
        mapboxToken,
      );
      ref.read(editProfileFormProvider.notifier).updateAddress(address);
    } catch (e) {
      // Manejar error silenciosamente o mostrar un mensaje
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(editProfileFormProvider);
    final notifier = ref.read(editProfileFormProvider.notifier);
    final submitState = ref.watch(editProfileViewModelProvider);

    _nameController.value = _nameController.value.copyWith(
      text: formState.name.value,
    );
    _dniController.value = _dniController.value.copyWith(
      text: formState.dni.value,
    );
    _phoneController.value = _phoneController.value.copyWith(
      text: formState.phone,
    );
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 56),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: AppTheme.white,
                    shadowColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _InputLabel('Nombre completo'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _nameController,
                            onChanged: notifier.updateName,
                            decoration: _inputDecoration(
                              hint: 'Ej: Juan Pérez',
                            ),
                          ),
                          if (formState.name.errorMessage != null)
                            _ErrorText(formState.name.errorMessage!),
                          const SizedBox(height: 16),

                          _InputLabel('DNI'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _dniController,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            onChanged: notifier.updateDni,
                            decoration: _inputDecoration(hint: 'Ej: 12345678'),
                          ),
                          if (formState.dni.errorMessage != null)
                            _ErrorText(formState.dni.errorMessage!),
                          const SizedBox(height: 16),

                          _InputLabel('Teléfono'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 9,
                            onChanged: notifier.updatePhone,
                            decoration: _inputDecoration(hint: 'Ej: 987654321'),
                          ),
                          const SizedBox(height: 16),


                          _InputLabel('Dirección'),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text:
                                        formState.address ??
                                        'Selecciona una ubicación',
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Tu dirección aparecerá aquí',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                if (formState.location != null)
                                  LocationMapPreview(
                                    location: formState.location!,
                                    height: 120,
                                    borderRadius: 0,
                                  ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: TextButton.icon(
                                    onPressed: () =>
                                        _showLocationEditModal(context, ref),
                                    icon: const Icon(
                                      Icons.edit_location,
                                      size: 18,
                                    ),
                                    label: const Text('Editar ubicación'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          NotificationPreferencesForm(
                            preferences: formState.notificationPreferences,
                            onChanged: notifier.updateNotificationPreferences,
                          ),
                          const SizedBox(height: 32),

                          if (formState.errorMessage != null)
                            _ErrorText(formState.errorMessage!),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              label: submitState.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Guardar cambios'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              onPressed: submitState.isLoading
                                  ? null
                                  : () async {
                                      final success = await ref
                                          .read(
                                            editProfileViewModelProvider
                                                .notifier,
                                          )
                                          .submit();
                                      if (context.mounted && success) {
                                        context.go('/settings');
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        border: Border.all(color: AppTheme.tertiary, width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppTheme.background,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      suffixIcon: suffixIcon,
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0C3751),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String error;
  const _ErrorText(this.error);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          error,
          style: const TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class NotificationPreferencesForm extends StatelessWidget {
  final NotificationPreferences preferences;
  final ValueChanged<NotificationPreferences> onChanged;

  const NotificationPreferencesForm({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text(
            'Alertas Diurnas',
            style: TextStyle(
              color: Color(0xFF0C3751),
              fontWeight: FontWeight.w600,
            ),
          ),
          value: preferences.daytimeAlerts,
          onChanged: (v) => onChanged(preferences.copyWith(daytimeAlerts: v)),
          activeColor: AppTheme.primary,
        ),
        if (preferences.daytimeAlerts) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Inicio Diurno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: preferences.daytimeStart,
                      decoration: _inputDecoration(hint: '06:00'),
                      onChanged: (v) =>
                          onChanged(preferences.copyWith(daytimeStart: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Fin Diurno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: preferences.daytimeEnd,
                      decoration: _inputDecoration(hint: '20:00'),
                      onChanged: (v) =>
                          onChanged(preferences.copyWith(daytimeEnd: v)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        SwitchListTile(
          title: const Text(
            'Alertas Nocturnas',
            style: TextStyle(
              color: Color(0xFF0C3751),
              fontWeight: FontWeight.w600,
            ),
          ),
          value: preferences.nighttimeAlerts,
          onChanged: (v) => onChanged(preferences.copyWith(nighttimeAlerts: v)),
          activeColor: AppTheme.primary,
        ),
        if (preferences.nighttimeAlerts) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Inicio Nocturno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: preferences.nighttimeStart,
                      decoration: _inputDecoration(hint: '20:00'),
                      onChanged: (v) =>
                          onChanged(preferences.copyWith(nighttimeStart: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('Fin Nocturno'),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: preferences.nighttimeEnd,
                      decoration: _inputDecoration(hint: '06:00'),
                      onChanged: (v) =>
                          onChanged(preferences.copyWith(nighttimeEnd: v)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _inputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0C3751),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
