import 'package:comaslimpio/core/presentation/widgets/admin_navigation_bar.dart';
import 'package:comaslimpio/core/presentation/widgets/citizen_bottom_navigation_bar.dart';
import 'package:comaslimpio/core/presentation/widgets/truck_driver_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/presentation/views/custom_app_bar.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;
  const MainScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(authProvider).userRole ?? 'citizen';

    return Scaffold(
      appBar: const CustomAppBar(),
      body: child,
      bottomNavigationBar: _buildBottomNavBar(userRole, context),
    );
  }

  Widget? _buildBottomNavBar(String role, BuildContext context) {
    switch (role) {
      case 'admin':
        return AdminBottomNavigationBar();
      case 'truck_driver':
        return TruckDriverBottomNavigationBar();
      case 'citizen':
      default:
        return CitizenBottomNavigationBar();
    }
  }
}
