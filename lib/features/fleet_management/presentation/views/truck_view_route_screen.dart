import 'package:flutter/material.dart';

class TruckViewRouteScreen extends StatelessWidget {
  const TruckViewRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla para ver rutas de camiones',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
