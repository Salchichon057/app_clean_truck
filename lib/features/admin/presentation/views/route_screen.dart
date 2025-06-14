import 'package:flutter/material.dart';

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla de rutas',
          style: Theme.of(context).textTheme.headlineSmall
        ),
      ),
    );
  }
}