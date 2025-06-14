import 'package:flutter/material.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Descripción del incidente',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí se manejaría el envío del reporte
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reporte enviado')),
                );
              },
              child: const Text('Enviar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}
