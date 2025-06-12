import 'package:comaslimpio/core/presentation/views/edit_profile_screen.dart';
import 'package:comaslimpio/core/presentation/views/settings_screen.dart';
import 'package:comaslimpio/core/presentation/views/main_screen.dart';
import 'package:comaslimpio/core/presentation/widgets/notifications_screen.dart';
import 'package:comaslimpio/features/auth/presentation/views/views_screen.dart';
import 'package:comaslimpio/features/truck_drive/presentation/views/truck_selection_screen.dart';
import 'package:comaslimpio/features/truck_drive/presentation/views/truck_view_route_screen.dart';
import 'package:comaslimpio/features/citizen/presentation/views/citizen_home_screen.dart';
import 'package:comaslimpio/features/citizen/presentation/views/citizen_incident_history_screen.dart';
import 'package:comaslimpio/features/admin/presentation/views/admin_add_truck_drivers_screen.dart';
import 'package:comaslimpio/features/admin/presentation/views/admin_add_trucks_screen.dart';
import 'package:comaslimpio/features/admin/presentation/views/admin_maps_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:comaslimpio/core/presentation/router/app_router_notifier.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // ! Notifications route
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          
          // ! Configuration route
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          GoRoute(path: '/settings/edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),

          // ! Admin routes
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminAddTruckDriversScreen(),
          ),

          GoRoute(
            path: '/admin/add_truck',
            builder: (context, state) => const AdminAddTrucksScreen(),
          ),

          GoRoute(
            path: '/admin/reports',
            builder: (context, state) => const AdminMapsScreen(),
          ),

          GoRoute(
            path: '/admin/map',
            builder: (context, state) => const AdminMapsScreen(),
          ),

          // ! Citizen routes
          GoRoute(
            path: '/citizen',
            builder: (context, state) => const CitizenHomeScreen(),
          ),
          GoRoute(
            path: '/citizen/history',
            builder: (context, state) => const CitizenIncidentHistoryScreen(),
          ),

          // ! Truck Driver routes
          GoRoute(
            path: '/truck_driver',
            builder: (context, state) => const TruckSelectionScreen(),
          ),
          GoRoute(
            path: '/truck_driver/map',
            builder: (context, state) => const TruckViewRouteScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authStatus = goRouterNotifier.authStatus;
      final isGoingTo = state.matchedLocation;

      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
        return null;
      }

      if (authStatus == AuthStatus.unauthenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/home') {
          return null;
        }
        return '/home';
      }

      if (authStatus == AuthStatus.authenticated) {
        final userRole = goRouterNotifier.userRole;
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/splash') {
          return '/$userRole';
        }
      }

      return null;
    },
  );
});
