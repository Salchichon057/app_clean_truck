import 'package:flutter/material.dart';

class AdminMapsScreen extends StatelessWidget {
  const AdminMapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Pantalla de mapas para administradores',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
