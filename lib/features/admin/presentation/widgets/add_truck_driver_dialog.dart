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
  late final TextEditingController _nameController;
  late final TextEditingController _dniController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final form = ref.read(addTruckDriverFormProvider);
    _nameController = TextEditingController(text: form.name.value);
    _dniController = TextEditingController(text: form.dni.value);
    _emailController = TextEditingController(text: form.email.value);
    _phoneController = TextEditingController(text: form.phone);
    _passwordController = TextEditingController(text: form.password.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addTruckDriverFormProvider);
    final viewModel = ref.watch(addTruckDriverViewModelProvider);

    // Sincroniza los controladores con el estado del formulario
    _nameController.value = _nameController.value.copyWith(
      text: form.name.value,
    );
    _dniController.value = _dniController.value.copyWith(text: form.dni.value);
    _emailController.value = _emailController.value.copyWith(
      text: form.email.value,
    );
    _phoneController.value = _phoneController.value.copyWith(text: form.phone);
    _passwordController.value = _passwordController.value.copyWith(
      text: form.password.value,
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: SingleChildScrollView(
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
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  label: 'Nombre completo',
                  icon: Icons.person,
                  errorText: form.name.errorMessage,
                ),
                onChanged: (v) =>
                    ref.read(addTruckDriverFormProvider.notifier).updateName(v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dniController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: _inputDecoration(
                  label: 'DNI',
                  icon: Icons.badge,
                  errorText: form.dni.errorMessage,
                ),
                onChanged: (v) =>
                    ref.read(addTruckDriverFormProvider.notifier).updateDni(v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  label: 'Correo electrónico',
                  icon: Icons.email,
                  errorText: form.email.errorMessage,
                ),
                onChanged: (v) => ref
                    .read(addTruckDriverFormProvider.notifier)
                    .updateEmail(v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                decoration: _inputDecoration(
                  label: 'Teléfono',
                  icon: Icons.phone,
                  errorText: form.phone.trim().isEmpty
                      ? 'Campo requerido'
                      : null,
                ),
                onChanged: (v) => ref
                    .read(addTruckDriverFormProvider.notifier)
                    .updatePhone(v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  label: 'Contraseña',
                  icon: Icons.lock,
                  errorText: form.password.errorMessage,
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
                onChanged: (v) => ref
                    .read(addTruckDriverFormProvider.notifier)
                    .updatePassword(v),
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
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      errorText: errorText,
      suffixIcon: suffixIcon,
    );
  }
}
