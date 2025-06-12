// ignore_for_file: use_build_context_synchronously

import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/core/services/geocoding_service.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dniController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  Location? _selectedLocation;
  bool _isLoading = false;
  String? _addressError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dniController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFields());
  }

  Future<void> _initFields() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _nameController.text = user.name;
      _dniController.text = user.dni;
      _phoneController.text = user.phoneNumber;
      _selectedLocation = user.location;
      // Obtener dirección legible
      final mapboxToken = await MapToken.getMapToken();
      final address = await GeocodingService.getAddressFromLatLng(
        user.location.lat,
        user.location.long,
        mapboxToken,
      );
      _addressController.text = address;
      setState(() {});
    }
  }

  Future<void> _onReverseGeocode(Location location) async {
    setState(() {
      _addressError = null;
      _isLoading = true;
    });
    final mapboxToken = await MapToken.getMapToken();
    final address = await GeocodingService.getAddressFromLatLng(
      location.lat,
      location.long,
      mapboxToken,
    );
    _addressController.text = address;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      setState(() => _addressError = "Selecciona una ubicación válida");
      return;
    }
    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final updatedUser = user.copyWith(
      name: _nameController.text.trim(),
      dni: _dniController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      location: _selectedLocation!,
    );

    try {
      await ref.read(authRepositoryProvider).updateUserProfile(updatedUser);
      await ref.read(authProvider.notifier).fetchUserData();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.background,
                    child: Icon(
                      Icons.person,
                      size: 56,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El nombre completo es obligatorio';
                    }
                    if (v.trim().length < 3) {
                      return 'Debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // DNI
                TextFormField(
                  controller: _dniController,
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El DNI es obligatorio';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(v)) {
                      return 'El DNI solo debe contener números';
                    }
                    if (v.length != 8) {
                      return 'El DNI debe tener exactamente 8 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El teléfono es obligatorio';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(v)) {
                      return 'El teléfono solo debe contener números';
                    }
                    if (v.length != 9) {
                      return 'El teléfono debe tener 9 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Dirección (solo lectura)
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    errorText: _addressError,
                  ),
                ),
                const SizedBox(height: 16),
                // Mapa para seleccionar ubicación
                _LocationPickerEdit(
                  initialLocation: _selectedLocation ?? user.location,
                  onLocationChanged: (loc) async {
                    setState(() {
                      _selectedLocation = loc;
                    });
                    await _onReverseGeocode(loc);
                  },
                ),
                const SizedBox(height: 32),
                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: _isLoading ? null : _onSave,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para seleccionar ubicación en modo edición (solo mueve el pin)
class _LocationPickerEdit extends StatefulWidget {
  final Location initialLocation;
  final ValueChanged<Location> onLocationChanged;

  const _LocationPickerEdit({
    required this.initialLocation,
    required this.onLocationChanged,
  });

  @override
  State<_LocationPickerEdit> createState() => _LocationPickerEditState();
}

class _LocationPickerEditState extends State<_LocationPickerEdit> {
  late MapController _mapController;
  late Location _currentLocation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: MapToken.getMapToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 'No token found') {
          return const Text('No se pudo cargar el mapa');
        }
        final mapboxToken = snapshot.data!;
        return SizedBox(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      _currentLocation.lat,
                      _currentLocation.long,
                    ),
                    initialZoom: 17,
                    onMapEvent: (event) {
                      if (event is MapEventMoveStart) {
                        setState(() => _isDragging = true);
                      }
                      if (event is MapEventMoveEnd) {
                        setState(() => _isDragging = false);
                        final center = event.camera.center;
                        final newLoc = Location(
                          lat: center.latitude,
                          long: center.longitude,
                        );
                        setState(() => _currentLocation = newLoc);
                        widget.onLocationChanged(newLoc);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                    ),
                  ],
                ),
                // Pin fijo en el centro
                IgnorePointer(
                  child: AnimatedScale(
                    scale: _isDragging ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
