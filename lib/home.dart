import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Crea una pantalla de inicio donde haya un botón de "ingresar" que al presionarlo muestre un mensaje de bienvenida y me redirija a una pantalla de "login" si no estoy autenticado.
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Aquí iría la lógica para mostrar un mensaje de bienvenida
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bienvenido a la aplicación!')),
            );
            // Redirigir a la pantalla de login si no estoy autenticado
            Navigator.pushNamed(context, '/login');
          },
          child: const Text('Ingresar'),
        ),
      ),
    );
  }
}
