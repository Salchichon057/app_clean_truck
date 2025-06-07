import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/navigation_provider.dart';

class AdminBottomNavigationBar extends ConsumerWidget {
  const AdminBottomNavigationBar({super.key});

  static const _routes = [
    '/admin',
    '/admin/add_truck',
    '/admin/reports',
    '/admin/map',
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
      items: [
        const BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.userPlus),
          label: 'Usuarios',
        ),
        const BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.truck),
          label: 'Camiones',
        ),
        const BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.list),
          label: 'Reportes',
        ),
        const BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.map),
          label: 'Mapa',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
