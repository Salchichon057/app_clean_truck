import 'package:flutter/material.dart';

class AdminAddTrucksScreen extends StatelessWidget {
  const AdminAddTrucksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla para agregar camiones',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
