import 'package:comaslimpio/register.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers
    // Aquí puedes agregar lógica para manejar el inicio de sesión, como validación de campos y autenticación con Firebase.
    // Creame un formulario de inicio de sesión simple con email y contraseña
    // Puedes usar TextEditingController para manejar los campos de texto si es necesario.
    // También puedes agregar validaciones y lógica de autenticación aquí.

    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para iniciar sesión
                // Por ejemplo, llamar a FirebaseAuth.instance.signInWithEmailAndPassword
              },
              child: const Text('Iniciar Sesión'),
            ),
            const SizedBox(height: 20),
            // Aun no tienes cuenta? Regístrate aquí
            TextButton(
              onPressed: () {
                // Redirigir a la pantalla de registro
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Register()),
                );
              },
              child: const Text('¿Aún no tienes cuenta? Regístrate aquí'),
            ),
          ],
        ),
      ),
    );
  }
}
