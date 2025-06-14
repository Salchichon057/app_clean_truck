import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/core/presentation/widgets/location_map_preview.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/report_incident_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class ReportIncidentScreen extends ConsumerWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reportar Incidente',
          style: TextStyle(color: Color.fromRGBO(0, 59, 86, 1)),
        ),
        iconTheme: const IconThemeData(color: Color.fromRGBO(0, 59, 86, 1)),
      ),
      body: const _ReportIncidentForm(),
    );
  }
}

class _ReportIncidentForm extends ConsumerStatefulWidget {
  const _ReportIncidentForm();

  @override
  ConsumerState<_ReportIncidentForm> createState() =>
      _ReportIncidentFormState();
}

class _ReportIncidentFormState extends ConsumerState<_ReportIncidentForm> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(reportIncidentFormProvider);
    final formNotifier = ref.read(reportIncidentFormProvider.notifier);
    final submitState = ref.watch(reportIncidentViewModelProvider);

    return Stack(
      children: [
        // Fondo degradado
        Container(
        ),
        Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción del incidente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe el incidente',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: formNotifier.updateDescription,
                    ),
                    if (formState.description.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          formState.description.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ubicación del incidente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _LocationSelector(),
                    if (formState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          formState.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.report, color: Colors.white),
                        label: submitState.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Reportar Incidente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: submitState.isLoading
                            ? null
                            : () async {
                                final success = await ref
                                    .read(
                                      reportIncidentViewModelProvider.notifier,
                                    )
                                    .submit();
                                if (success && context.mounted) {
                                  context.pop();
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationSelector extends ConsumerStatefulWidget {
  @override
  ConsumerState<_LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<_LocationSelector> {
  Future<void> _showLocationEditModal(BuildContext context) async {
    final formState = ref.read(reportIncidentFormProvider);
    final notifier = ref.read(reportIncidentFormProvider.notifier);

    final result = await showDialog<Location>(
      context: context,
      builder: (context) => IncidentLocationEditModal(
        initialLocation: formState.incidentLocation,
        // Puedes pasar la ubicación de la casa del usuario aquí si la tienes
        // userHomeLocation: ...
      ),
    );

    if (result != null) {
      notifier.updateIncidentLocation(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(reportIncidentFormProvider);

    return Column(
      children: [
        if (formState.incidentLocation != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LocationMapPreview(location: formState.incidentLocation!),
          ),
        ElevatedButton.icon(
          onPressed: () => _showLocationEditModal(context),
          icon: const Icon(Icons.location_on, color: AppTheme.primary),
          label: const Text('Seleccionar Ubicación del Incidente'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primary,
            side: const BorderSide(color: AppTheme.primary, width: 1.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class IncidentLocationEditModal extends StatefulWidget {
  final Location? initialLocation;
  // final Location? userHomeLocation; // Si quieres mostrar la casa del usuario

  const IncidentLocationEditModal({
    super.key,
    this.initialLocation,
    // this.userHomeLocation,
  });

  @override
  State<IncidentLocationEditModal> createState() =>
      _IncidentLocationEditModalState();
}

class _IncidentLocationEditModalState extends State<IncidentLocationEditModal> {
  late MapController _mapController;
  late Location _selectedLocation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation =
        widget.initialLocation ??
        Location(lat: -12.0464, long: -77.0428); // Lima por defecto
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.edit_location, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Seleccionar ubicación del incidente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Arrastra el mapa para seleccionar la ubicación del incidente.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<String>(
                future: MapToken.getMapToken(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 'No token found') {
                    return const Center(
                      child: Text('No se pudo cargar el mapa'),
                    );
                  }
                  final mapboxToken = snapshot.data!;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              _selectedLocation.lat,
                              _selectedLocation.long,
                            ),
                            initialZoom: 17,
                            onMapEvent: (event) {
                              if (event is MapEventMoveStart) {
                                setState(() => _isDragging = true);
                              }
                              if (event is MapEventMoveEnd) {
                                setState(() => _isDragging = false);
                                final center = event.camera.center;
                                _selectedLocation = Location(
                                  lat: center.latitude,
                                  long: center.longitude,
                                );
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                    _selectedLocation.lat,
                                    _selectedLocation.long,
                                  ),
                                  width: 44,
                                  height: 44,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 44,
                                  ),
                                ),
                                // Si quieres mostrar la casa del usuario:
                                // if (widget.userHomeLocation != null)
                                //   Marker(
                                //     point: LatLng(
                                //       widget.userHomeLocation!.lat,
                                //       widget.userHomeLocation!.long,
                                //     ),
                                //     width: 36,
                                //     height: 36,
                                //     child: const Icon(
                                //       Icons.home,
                                //       color: Colors.blue,
                                //       size: 36,
                                //     ),
                                //   ),
                              ],
                            ),
                          ],
                        ),
                        IgnorePointer(
                          child: AnimatedScale(
                            scale: _isDragging ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 44,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedLocation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
