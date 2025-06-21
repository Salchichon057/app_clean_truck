import 'package:comaslimpio/features/admin/presentation/providers/add_truck_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import '../viewmodels/add_truck_driver_viewmodel.dart';

class AddTruckDriverDialog extends ConsumerStatefulWidget {
  const AddTruckDriverDialog({super.key});

  @override
  ConsumerState<AddTruckDriverDialog> createState() =>
      _AddTruckDriverDialogState();
}

class _AddTruckDriverDialogState extends ConsumerState<AddTruckDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addTruckDriverFormProvider);
    final viewModel = ref.watch(addTruckDriverViewModelProvider);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Agregar Conductor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (v) => ref
                      .read(addTruckDriverFormProvider.notifier)
                      .updateName(v),
                  validator: (_) => form.name.errorMessage,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  onChanged: (v) => ref
                      .read(addTruckDriverFormProvider.notifier)
                      .updateDni(v),
                  validator: (_) => form.dni.errorMessage,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => ref
                      .read(addTruckDriverFormProvider.notifier)
                      .updateEmail(v),
                  validator: (_) => form.email.errorMessage,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => ref
                      .read(addTruckDriverFormProvider.notifier)
                      .updatePhone(v),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  onChanged: (v) => ref
                      .read(addTruckDriverFormProvider.notifier)
                      .updatePassword(v),
                  validator: (_) => form.password.errorMessage,
                ),
                const SizedBox(height: 18),
                if (form.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      form.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            await ref
                                .read(addTruckDriverViewModelProvider.notifier)
                                .submit();
                            final error = ref
                                .read(addTruckDriverFormProvider)
                                .errorMessage;
                            if (error == null && mounted)
                              Navigator.of(context).pop();
                          },
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Guardar'),
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
