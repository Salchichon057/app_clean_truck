import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/navigation_provider.dart';

class TruckDriverBottomNavigationBar extends ConsumerWidget {
  const TruckDriverBottomNavigationBar({super.key});

  static const _routes = [
    '/truck_driver', // Seleccionar camión
    '/truck_driver/map', // Mapa de la ruta
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(navigationProvider.notifier).updateIndex(index);
        context.go(_routes[index]);
      },

      items: const [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.truck),
          label: 'Seleccionar Camión',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.route),
          label: 'Ruta',
        ),
      ],
    );
  }
}
