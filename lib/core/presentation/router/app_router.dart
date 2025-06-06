import 'package:comaslimpio/features/auth/presentation/views/views_screen.dart';
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
      GoRoute(
        path: '/home', // Pantalla inicial "Bienvenido"
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Agregar rutas para roles (admin, citizen, truck_driver) más adelante
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
        final userRole =
            goRouterNotifier.userRole; // Obtener rol desde el notificador
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/splash') {
          return '/${userRole.toLowerCase()}'; // Redirigir según rol (e.g., /citizen, /admin)
        }
      }

      return null;
    },
  );
});
