import 'package:flutter/material.dart';

class TruckSelectionScreen extends StatelessWidget {
  const TruckSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla para seleccionar camiones',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
