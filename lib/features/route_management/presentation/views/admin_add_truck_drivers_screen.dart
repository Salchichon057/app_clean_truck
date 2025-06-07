import 'package:flutter/material.dart';

class AdminAddTruckDriversScreen extends StatelessWidget {
  const AdminAddTruckDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla para agregar conductores de camiones',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
