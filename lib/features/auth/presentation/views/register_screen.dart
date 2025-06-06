import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/features/auth/presentation/components/register_form.dart';
import 'package:comaslimpio/features/auth/presentation/viewmodels/register_viewmodel.dart';
import 'package:comaslimpio/core/components/map/map_location_provider.dart'; // Nueva importación
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      ref
          .read(registerViewModelProvider.notifier)
          .onNameChanged(_nameController.text);
    });
    _emailController.addListener(() {
      ref
          .read(registerViewModelProvider.notifier)
          .onEmailChanged(_emailController.text);
    });
    _phoneController.addListener(() {
      ref
          .read(registerViewModelProvider.notifier)
          .onPhoneChanged(_phoneController.text);
    });
    _passwordController.addListener(() {
      ref
          .read(registerViewModelProvider.notifier)
          .onPasswordChanged(_passwordController.text);
    });
    _confirmPasswordController.addListener(() {
      // Validar que coincida con _passwordController si es necesario
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);
    final mapLocationState = ref.watch(mapLocationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro', style: TextStyle(color: AppTheme.white)),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Image.asset(
              'assets/logo_comas.png',
              height: 100,
            ), // Asegúrate de agregar el logo
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre Completo',
                        errorText:
                            registerState.name.error ==
                                NameValidationError.empty
                            ? 'El nombre no puede estar vacío'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        errorText: registerState.email.error != null
                            ? registerState.email.error ==
                                      EmailValidationError.empty
                                  ? 'El correo no puede estar vacío'
                                  : 'Correo inválido'
                            : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Número de Teléfono',
                        errorText: registerState.phone.error != null
                            ? registerState.phone.error ==
                                      PhoneValidationError.empty
                                  ? 'El teléfono no puede estar vacío'
                                  : 'Teléfono inválido (10 dígitos)'
                            : null,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        errorText: registerState.password.error != null
                            ? registerState.password.error ==
                                      PasswordValidationError.empty
                                  ? 'La contraseña no puede estar vacía'
                                  : 'La contraseña debe tener al menos 6 caracteres'
                            : null,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ubicación',
                      style: TextStyle(fontSize: 16, color: AppTheme.secondary),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              mapLocationState.currentLocation != null
                              ? LatLng(
                                  mapLocationState.currentLocation!.lat,
                                  mapLocationState.currentLocation!.long,
                                )
                              : const LatLng(-12.0464, -77.0428),
                          initialZoom: 15.0,
                          onTap: (tapPosition, point) {
                            final newLocation = Location(
                              lat: point.latitude,
                              long: point.longitude,
                            );
                            ref
                                .read(mapLocationProvider.notifier)
                                .updateSelectedLocation(newLocation);
                            ref
                                .read(registerViewModelProvider.notifier)
                                .onLocationChanged(newLocation);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              if (mapLocationState.selectedLocation != null)
                                Marker(
                                  point: LatLng(
                                    mapLocationState.selectedLocation!.lat,
                                    mapLocationState.selectedLocation!.long,
                                  ),
                                  width: 80,
                                  height: 80,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: AppTheme.primary,
                                    size: 40,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (registerState.location.error ==
                        LocationValidationError.empty)
                      const Text(
                        'Debes seleccionar una ubicación',
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            registerState.isValid &&
                                mapLocationState.selectedLocation != null &&
                                !registerState.isSubmitting &&
                                _passwordController.text ==
                                    _confirmPasswordController.text
                            ? () async {
                                await ref
                                    .read(registerViewModelProvider.notifier)
                                    .submit();
                                if (registerState.errorMessage == null) {
                                  context.go('/citizen');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        registerState.errorMessage!,
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: registerState.isSubmitting
                            ? const CircularProgressIndicator(
                                color: AppTheme.white,
                              )
                            : const Text('Registrarse'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: const Text(
                '¿Ya tienes cuenta? Inicia sesión aquí',
                style: TextStyle(
                  color: AppTheme.tertiary,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
