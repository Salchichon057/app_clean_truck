import 'package:flutter/material.dart';

class CitizenIncidentHistoryScreen extends StatelessWidget {
  const CitizenIncidentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Aquí se mostrará el historial de incidentes reportados.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
