import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAddTrucksScreen extends ConsumerWidget {
  const AdminAddTrucksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
