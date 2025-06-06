import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No new notifications'),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para navegar a otras pantallas
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
