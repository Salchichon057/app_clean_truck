import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';

class TruckFormDialog extends ConsumerStatefulWidget {
  final Truck? truck;
  const TruckFormDialog({super.key, this.truck});

  @override
  ConsumerState<TruckFormDialog> createState() => _TruckFormDialogState();
}

class _TruckFormDialogState extends ConsumerState<TruckFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController idController;
  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController yearController;
  late TextEditingController serialController;
  late TextEditingController colorController;
  late TextEditingController engineController;
  late TextEditingController typeController;
  String status = 'available';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    final t = widget.truck;
    idController = TextEditingController(text: t?.idTruck ?? '');
    brandController = TextEditingController(text: t?.brand ?? '');
    modelController = TextEditingController(text: t?.model ?? '');
    yearController = TextEditingController(
      text: t?.yearOfManufacture.toString() ?? '',
    );
    serialController = TextEditingController(text: t?.serialNumber ?? '');
    colorController = TextEditingController(text: t?.color ?? '');
    engineController = TextEditingController(text: t?.engineNumber ?? '');
    typeController = TextEditingController(text: t?.vehicleType ?? '');
    status = t?.status ?? 'available';
  }

  @override
  Widget build(BuildContext context) {
    final truckNotifier = ref.read(truckViewModelProvider.notifier);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título fijo arriba
              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 24,
                  right: 24,
                  bottom: 0,
                ),
                child: Text(
                  widget.truck == null ? 'Agregar Camión' : 'Editar Camión',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _InputLabel('Placa'),
                        TextFormField(
                          controller: idController,
                          decoration: _inputDecoration(hint: 'Ej: ABC-123'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obligatorio' : null,
                          enabled: widget.truck == null,
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('Marca'),
                        TextFormField(
                          controller: brandController,
                          decoration: _inputDecoration(hint: 'Ej: Volvo'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obligatorio' : null,
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('Modelo'),
                        TextFormField(
                          controller: modelController,
                          decoration: _inputDecoration(hint: 'Ej: FH16'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obligatorio' : null,
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('Año de fabricación'),
                        TextFormField(
                          controller: yearController,
                          decoration: _inputDecoration(hint: 'Ej: 2020'),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obligatorio' : null,
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('N° de serie'),
                        TextFormField(
                          controller: serialController,
                          decoration: _inputDecoration(hint: 'Opcional'),
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('Color'),
                        TextFormField(
                          controller: colorController,
                          decoration: _inputDecoration(hint: 'Opcional'),
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('N° de motor'),
                        TextFormField(
                          controller: engineController,
                          decoration: _inputDecoration(hint: 'Opcional'),
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('Tipo de vehículo'),
                        TextFormField(
                          controller: typeController,
                          decoration: _inputDecoration(hint: 'Ej: Volquete'),
                        ),
                        const SizedBox(height: 12),
                        _InputLabel('Estado'),
                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(canvasColor: Colors.white),
                          child: DropdownButtonFormField<String>(
                            value: status,
                            decoration: _inputDecoration(hint: ''),
                            items: const [
                              DropdownMenuItem(
                                value: 'available',
                                child: Text('Disponible'),
                              ),
                              DropdownMenuItem(
                                value: 'unavailable',
                                child: Text('No disponible'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => status = v ?? 'available'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (errorMessage != null) _ErrorText(errorMessage!),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          setState(() => errorMessage = null);
                          if (_formKey.currentState?.validate() != true) return;
                          try {
                            final truck = Truck(
                              idTruck: idController.text.trim(),
                              brand: brandController.text.trim(),
                              model: modelController.text.trim(),
                              yearOfManufacture:
                                  int.tryParse(yearController.text.trim()) ?? 0,
                              serialNumber: serialController.text.trim(),
                              color: colorController.text.trim(),
                              engineNumber: engineController.text.trim(),
                              vehicleType: typeController.text.trim(),
                              status: status,
                            );
                            if (widget.truck == null) {
                              await truckNotifier.addTruck(truck);
                            } else {
                              await truckNotifier.updateTruck(truck);
                            }
                            if (mounted) Navigator.pop(context);
                          } catch (e) {
                            setState(() => errorMessage = 'Error al guardar');
                          }
                        },
                        child: Text(
                          widget.truck == null ? 'Agregar' : 'Guardar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.only(top: 2, left: 4, bottom: 8),
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
