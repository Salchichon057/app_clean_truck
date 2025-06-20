import 'package:comaslimpio/core/inputs/dni.dart';
import 'package:comaslimpio/core/inputs/email.dart';
import 'package:comaslimpio/core/inputs/full_name.dart';
import 'package:comaslimpio/core/inputs/password.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';
import 'package:comaslimpio/features/auth/domain/models/notification_preferences.dart';
import 'package:comaslimpio/features/auth/infrastructure/mappers/app_user_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTruckDriverDialog extends StatefulWidget {
  const AddTruckDriverDialog({super.key});

  @override
  State<AddTruckDriverDialog> createState() => _AddTruckDriverDialogState();
}

class _AddTruckDriverDialogState extends State<AddTruckDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  static final Location defaultLocation = Location(
    lat: -11.9498,
    long: -77.0622,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addDriver() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userCredential = await FirebaseFirestore.instance
          .collection('app_users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (userCredential.docs.isNotEmpty) {
        setState(() {
          _error = 'Ya existe un usuario con ese correo.';
          _isLoading = false;
        });
        return;
      }

      final auth = FirebaseAuth.instance;
      final userCred = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final uid = userCred.user?.uid;
      if (uid == null) throw Exception('No se pudo crear el usuario');

      final appUser = AppUser(
        uid: uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dni: _dniController.text.trim(),
        role: 'truck_driver',
        location: defaultLocation,
        status: 'active',
        createdAt: Timestamp.now(),
        notificationPreferences: NotificationPreferences(
          daytimeAlerts: true,
          nighttimeAlerts: true,
          daytimeStart: '06:00',
          daytimeEnd: '20:00',
          nighttimeStart: '20:00',
          nighttimeEnd: '06:00',
        ),
      );

      await FirebaseFirestore.instance
          .collection('app_users')
          .doc(uid)
          .set(AppUserMapper.toJson(appUser));

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) {
                    final input = FullName.dirty(v ?? '');
                    return input.errorMessage;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dniController,
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  validator: (v) {
                    final input = Dni.dirty(v ?? '');
                    return input.errorMessage;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final input = Email.dirty(v ?? '');
                    return input.errorMessage;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) {
                    final input = Password.dirty(v ?? '');
                    return input.errorMessage;
                  },
                ),
                const SizedBox(height: 18),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save, color: Colors.white),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isLoading ? null : _addDriver,
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
