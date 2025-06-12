import 'package:flutter/material.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Bienvenido a la aplicación Ciudadano',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}