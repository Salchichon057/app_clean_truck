import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:comaslimpio/core/services/notification_preferences_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Mostrar diálogo de notificaciones después de que se construya la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowNotificationDialog();
    });
  }

  Future<void> _checkAndShowNotificationDialog() async {
    if (await NotificationPreferencesService.isFirstTimeAskingPermissions()) {
      if (mounted) {
        await NotificationPreferencesService.showNotificationPermissionDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF41A5DE), Color(0xFF226D9A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            top: -90,
            left: -14,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: -90,
            left: -190,
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -90,
            right: -14,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -90,
            right: -190,
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 60),
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/trash_image.png', height: 120),

                      const SizedBox(height: 24),

                      const Text(
                        'BIENVENIDO',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0C3751),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Sistema Gestión de Recojo\nde Basura del Distrito de Comas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0C3751),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0C3751),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            context.go('/login');
                          },
                          child: const Text(
                            'Comenzar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 0,
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 120,
                    semanticsLabel: 'Escudo de la Municipalidad',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
