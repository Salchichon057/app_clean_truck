// ignore_for_file: use_build_context_synchronously

import 'package:comaslimpio/core/config/map_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/auth/presentation/providers/register_form_provider.dart';
import 'package:comaslimpio/features/auth/presentation/viewmodels/register_viewmodel.dart';
import 'package:comaslimpio/core/components/map/map_location_provider.dart';
import 'package:comaslimpio/features/auth/presentation/components/step1_personal_info.dart';
import 'package:comaslimpio/features/auth/presentation/components/step2_location.dart';
import 'package:comaslimpio/features/auth/presentation/components/step3_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final MapController _mapController = MapController();
  bool _isProgrammaticChange = false;
  bool _isLocationInitialized = false; // Nueva bandera

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (_isProgrammaticChange) return;
      ref
          .read(registerFormProvider.notifier)
          .updateName(_nameController.text.trim());
    });
    _lastNameController.addListener(() {
      if (_isProgrammaticChange) return;
      ref
          .read(registerFormProvider.notifier)
          .updateLastName(_lastNameController.text.trim());
    });
    _emailController.addListener(() {
      if (_isProgrammaticChange) return;
      ref
          .read(registerFormProvider.notifier)
          .updateEmail(_emailController.text.trim());
    });
    _passwordController.addListener(() {
      if (_isProgrammaticChange) return;
      ref
          .read(registerFormProvider.notifier)
          .updatePassword(_passwordController.text.trim());
    });
    _confirmPasswordController.addListener(() {
      if (_isProgrammaticChange) return;
      ref
          .read(registerFormProvider.notifier)
          .updateConfirmPassword(_confirmPasswordController.text.trim());
    });

    if (!_isLocationInitialized) {
      final mapLocationNotifier = ref.read(mapLocationProvider.notifier);
      mapLocationNotifier.initLocation().then((_) {
        final mapLocationState = ref.read(mapLocationProvider);
        if (mapLocationState.currentLocation != null) {
          _confirmLocation();
          _isLocationInitialized = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(Location location) async {
    final mapboxToken = await MapToken.getMapToken();
    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${location.long},${location.lat}.json?access_token=$mapboxToken&language=es',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'].isNotEmpty) {
          final address = data['features'][0]['place_name'];
          _isProgrammaticChange = true;
          _addressController.text = address;
          _isProgrammaticChange = false;
          ref.read(registerFormProvider.notifier).updateAddress(address);
          ref.read(mapLocationProvider.notifier).updateCurrentAddress(address);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener la dirección')),
      );
    }
  }

  void _confirmLocation() {
    final mapLocationState = ref.read(mapLocationProvider);
    if (mapLocationState.selectedLocation != null) {
      ref
          .read(registerFormProvider.notifier)
          .updateLocation(mapLocationState.selectedLocation!);
      _isProgrammaticChange = true;
      _addressController.text = mapLocationState.currentAddress ?? '';
      _isProgrammaticChange = false;
      ref
          .read(registerFormProvider.notifier)
          .updateAddress(mapLocationState.currentAddress ?? '');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una ubicación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(registerFormProvider);
    final registerState = ref.watch(registerViewModelProvider);
    final mapLocationState = ref.watch(mapLocationProvider);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/logo.svg',
                height: 100,
                semanticsLabel: 'Escudo de la Municipalidad',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: formState.step == index
                          ? AppTheme.primary
                          : Colors.grey,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              if (formState.step == 0)
                Step1PersonalInfo(
                  nameController: _nameController,
                  lastNameController: _lastNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  onToggleObscurePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onToggleObscureConfirmPassword: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                )
              else if (formState.step == 1)
                Step2Location(
                  addressController: _addressController,
                  mapController: _mapController,
                  isDragging: false,
                  onConfirmLocation: _confirmLocation,
                  onReverseGeocode: _reverseGeocode,
                  mapLocationState: mapLocationState,
                )
              else if (formState.step == 2)
                Step3Notifications(
                  onUpdateDaytimeAlerts: (value) => ref
                      .read(registerFormProvider.notifier)
                      .updateDaytimeAlerts(value),
                  onUpdateNighttimeAlerts: (value) => ref
                      .read(registerFormProvider.notifier)
                      .updateNighttimeAlerts(value),
                  onUpdateDaytimeStart: (value) => ref
                      .read(registerFormProvider.notifier)
                      .updateDaytimeStart(value),
                  onUpdateDaytimeEnd: (value) => ref
                      .read(registerFormProvider.notifier)
                      .updateDaytimeEnd(value),
                  onUpdateNighttimeStart: (value) => ref
                      .read(registerFormProvider.notifier)
                      .updateNighttimeStart(value),
                  onUpdateNighttimeEnd: (value) => ref
                      .read(registerFormProvider.notifier)
                      .updateNighttimeEnd(value),
                  formState: formState,
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (formState.step > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(registerFormProvider.notifier)
                              .previousStep();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF226D9A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Anterior',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (formState.step > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: formState.step < 2
                          ? () {
                              final error = ref
                                  .read(registerFormProvider.notifier)
                                  .nextStep();
                              if (error != null) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(error)));
                              }
                            }
                          : registerState.isLoading
                          ? null
                          : () async {
                              final formState = ref.read(registerFormProvider);
                              if (!formState.isValid ||
                                  formState.location == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Por favor, completa todos los campos correctamente y selecciona una ubicación',
                                    ),
                                  ),
                                );
                                return;
                              }
                              await ref
                                  .read(registerViewModelProvider.notifier)
                                  .submit();
                              final updatedFormState = ref.read(
                                registerFormProvider,
                              );
                              if (updatedFormState.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      updatedFormState.errorMessage!,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/citizen/map');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B56),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: registerState.isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1,
                            )
                          : Text(
                              formState.step < 2 ? 'Siguiente' : 'Registrarse',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes cuenta?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0C3751),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF226D9A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
