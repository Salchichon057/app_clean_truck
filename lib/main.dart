import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/config/environmets.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/core/services/firebase_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/config/firebase_options.dart';
import 'core/presentation/router/app_router.dart';
import 'core/services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar manejador de notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inicializar Firebase Messaging y solicitar permisos (iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Inicializar servicio de notificaciones
  await FirebaseMessagingService.initialize();

  // Configurar Firestore para soporte offline a través del servicio
  FirestoreService.instance.configureSettings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Inicializar variables de entorno (CRÍTICO - debe cargar o fallar)
  try {
    await Environment.initEnvironment();
  } catch (e) {
    // En producción, la app no debe iniciarse si falla la configuración
    return;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
