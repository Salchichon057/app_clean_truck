import 'package:flutter/material.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF08273A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí se manejaría la lógica para guardar los cambios
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
