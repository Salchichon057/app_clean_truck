import 'package:comaslimpio/features/auth/presentation/providers/register_form_provider.dart';
import 'package:flutter/material.dart';

class Step1PersonalInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController lastNameController;
  final TextEditingController dniController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onToggleObscureConfirmPassword;
  // Agregamos para el formState
  final RegisterFormState formState;

  const Step1PersonalInfo({
    super.key,
    required this.nameController,
    required this.lastNameController,
    required this.dniController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onToggleObscurePassword,
    required this.onToggleObscureConfirmPassword,
    required this.formState,
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
        if (formState.name.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formState.name.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        _InputLabel('Apellido'),
        const SizedBox(height: 4),
        TextField(
          controller: lastNameController,
          decoration: _inputDecoration(hint: 'Pérez'),
        ),
        if (formState.lastName.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formState.lastName.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        _InputLabel('DNI'),
        const SizedBox(height: 4),
        TextField(
          controller: dniController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint: '12345678'),
        ),
        if (formState.dni.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formState.dni.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),

        _InputLabel('Correo Electrónico'),
        const SizedBox(height: 4),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(hint: 'juan.perez@example.com'),
        ),
        if (formState.email.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formState.email.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
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
        if (formState.password.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formState.password.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
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
        if (formState.confirmPassword.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formState.confirmPassword.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
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
