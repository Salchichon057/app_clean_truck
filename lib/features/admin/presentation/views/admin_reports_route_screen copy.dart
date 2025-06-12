import 'package:flutter/material.dart';

class AdminReportsRouteScreen extends StatelessWidget {
  const AdminReportsRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla de reportes de rutas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
