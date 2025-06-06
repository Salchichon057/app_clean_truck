import 'package:flutter/material.dart';

class Step1PersonalInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirmPassword;

  const Step1PersonalInfo({
    super.key,
    required this.nameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputLabel('Nombre'),
        const SizedBox(height: 4),
        TextField(
          controller: nameController,
          decoration: _inputDecoration(hint: 'Juan'),
        ),
        const SizedBox(height: 16),
        _InputLabel('Apellido'),
        const SizedBox(height: 4),
        TextField(
          controller: lastNameController,
          decoration: _inputDecoration(hint: 'Pérez'),
        ),
        const SizedBox(height: 16),
        _InputLabel('Correo Electrónico'),
        const SizedBox(height: 4),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hint: 'juan.perez@example.com'),
        ),
        const SizedBox(height: 16),
        _InputLabel('Contraseña'),
        const SizedBox(height: 4),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: _inputDecoration(
            hint: 'Ingresa tu contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggleObscurePassword,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _InputLabel('Confirmar Contraseña'),
        const SizedBox(height: 4),
        TextField(
          controller: confirmPasswordController,
          obscureText: obscureConfirmPassword,
          decoration: _inputDecoration(
            hint: 'Confirma tu contraseña',
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: onToggleObscureConfirmPassword,
            ),
          ),
        ),
      ],
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
