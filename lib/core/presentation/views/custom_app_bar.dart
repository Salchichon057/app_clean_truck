import 'package:comaslimpio/core/presentation/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

String getRoleLabel(String? role) {
  switch (role) {
    case 'admin':
      return 'Administrador';
    case 'truck_driver':
      return 'Conductor';
    case 'citizen':
    default:
      return 'Ciudadano';
  }
}

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(currentUserNameProvider) ?? 'Usuario';
    final userRole = ref.watch(authProvider).userRole;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          SvgPicture.asset('assets/icons/logo.svg', width: 36, height: 36),
          const Spacer(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                color: const Color(0xFF08273A),
                onPressed: () {
                  context.go('/notifications');
                },
              ),
              const SizedBox(width: 5),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: const Color(0xFFE8F7FF),
                  radius: 16,
                  child: SvgPicture.asset(
                    'assets/icons/user-icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF08273A),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if
                  // (value == 'profile') {
                  //   context.go('/profile');
                  // }
                  // else if
                  (value == 'settings') {
                    context.go('/settings');
                  } else if (value == 'logout') {
                    ref.read(navigationProvider.notifier).reset();
                    ref.read(authProvider.notifier).signOut();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getRoleLabel(userRole),
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings, color: Colors.blueGrey),
                        title: Text(
                          'Configuración',
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout, color: Colors.redAccent),
                        title: Text(
                          'Cerrar sesión',
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
