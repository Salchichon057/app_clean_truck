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
  late final ScrollController _scrollController;
  bool _obscurePassword = true;
  
  // Keys para cada campo
  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _dniKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _phoneKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final form = ref.read(addTruckDriverFormProvider);
    _nameController = TextEditingController(text: form.name.value);
    _dniController = TextEditingController(text: form.dni.value);
    _emailController = TextEditingController(text: form.email.value);
    _phoneController = TextEditingController(text: form.phone.value);
    _passwordController = TextEditingController(text: form.password.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToFirstError() {
    final form = ref.read(addTruckDriverFormProvider);
    GlobalKey? firstErrorKey;
    
    if (form.name.errorMessage != null) {
      firstErrorKey = _nameKey;
    } else if (form.dni.errorMessage != null) {
      firstErrorKey = _dniKey;
    } else if (form.email.errorMessage != null) {
      firstErrorKey = _emailKey;
    } else if (form.phone.errorMessage != null) {
      firstErrorKey = _phoneKey;
    } else if (form.password.errorMessage != null) {
      firstErrorKey = _passwordKey;
    }
    
    if (firstErrorKey != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final context = firstErrorKey?.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
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
    _phoneController.value = _phoneController.value.copyWith(text: form.phone.value);
    _passwordController.value = _passwordController.value.copyWith(
      text: form.password.value,
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: SingleChildScrollView(
          controller: _scrollController,
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
                key: _nameKey,
                controller: _nameController,
                decoration: _inputDecoration(
                  label: 'Nombre completo *',
                  icon: Icons.person,
                  errorText: form.name.errorMessage,
                ),
                onChanged: (v) =>
                    ref.read(addTruckDriverFormProvider.notifier).updateName(v),
              ),
              const SizedBox(height: 12),
              TextField(
                key: _dniKey,
                controller: _dniController,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: _inputDecoration(
                  label: 'DNI *',
                  icon: Icons.badge,
                  errorText: form.dni.errorMessage,
                ),
                onChanged: (v) =>
                    ref.read(addTruckDriverFormProvider.notifier).updateDni(v),
              ),
              const SizedBox(height: 12),
              TextField(
                key: _emailKey,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  label: 'Correo electrónico *',
                  icon: Icons.email,
                  errorText: form.email.errorMessage,
                ),
                onChanged: (v) => ref
                    .read(addTruckDriverFormProvider.notifier)
                    .updateEmail(v),
              ),
              const SizedBox(height: 12),
              TextField(
                key: _phoneKey,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                decoration: _inputDecoration(
                  label: 'Teléfono *',
                  icon: Icons.phone,
                  errorText: form.phone.errorMessage,
                ),
                onChanged: (v) => ref
                    .read(addTruckDriverFormProvider.notifier)
                    .updatePhone(v),
              ),
              const SizedBox(height: 12),
              TextField(
                key: _passwordKey,
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(
                  label: 'Contraseña *',
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
                          // Ejecutar submit y esperar resultado
                          await ref
                              .read(addTruckDriverViewModelProvider.notifier)
                              .submit();
                          
                          if (!mounted) return;
                          
                          final error = ref
                              .read(addTruckDriverFormProvider)
                              .errorMessage;
                          
                          if (error == null) {
                            // Éxito: mostrar SnackBar y cerrar diálogo
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conductor agregado correctamente'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } else {
                            // Error: hacer scroll al primer campo con error
                            _scrollToFirstError();
                          }
                          // Si hay error, se muestra en el Text widget de arriba
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
