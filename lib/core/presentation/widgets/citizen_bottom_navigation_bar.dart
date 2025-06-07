import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/navigation_provider.dart';

class CitizenBottomNavigationBar extends ConsumerWidget {
  const CitizenBottomNavigationBar({super.key});

  static const _routes = [
    '/citizen',
    '/citizen/history',
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
          icon: FaIcon(FontAwesomeIcons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.clock),
          label: 'Historial',
        ),
      ],
    );
  }
}
