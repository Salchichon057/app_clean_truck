import 'package:comaslimpio/core/presentation/widgets/location_map_preview.dart';
import 'package:comaslimpio/core/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final enabled = await NotificationPreferencesService.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      await NotificationPreferencesService.enableNotifications();
    } else {
      await NotificationPreferencesService.disableNotifications();
    }
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final addressAsync = ref.watch(userAddressProvider);

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: user == null
                ? const Center(child: Text('No hay datos de usuario'))
                : Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 56),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 600),
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: AppTheme.white,
                              shadowColor: AppTheme.primary.withValues(alpha: 0.2),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  80,
                                  24,
                                  32,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        getRoleLabel(user.role),
                                        style: const TextStyle(
                                          color: AppTheme.secondary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _ProfileDetail(
                                        label: 'Correo',
                                        value: user.email,
                                      ),
                                      _ProfileDetail(
                                        label: 'DNI',
                                        value: user.dni,
                                      ),
                                      _ProfileDetail(
                                        label: 'Teléfono',
                                        value: user.phoneNumber,
                                      ),
                                      addressAsync.when(
                                        data: (address) => _ProfileDetail(
                                          label: 'Dirección',
                                          value: address ?? '-',
                                        ),
                                        loading: () => const _ProfileDetail(
                                          label: 'Dirección',
                                          value: 'Cargando...',
                                        ),
                                        error: (_, __) => const _ProfileDetail(
                                          label: 'Dirección',
                                          value: 'No disponible',
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Sección de Notificaciones
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.background,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppTheme.tertiary.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: SwitchListTile(
                                          title: const Text(
                                            'Notificaciones',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          subtitle: const Text(
                                            'Recibir avisos cuando el camión pase por su domicilio',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 13,
                                            ),
                                          ),
                                          value: _notificationsEnabled,
                                          onChanged: _toggleNotifications,
                                          activeColor: AppTheme.tertiary,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      LocationMapPreview(
                                        location: user.location,
                                        height: 160,
                                        borderRadius: 10,
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Avatar flotante
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppTheme.tertiary,
                                  width: 4,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: AppTheme.background,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Botón editar flotante
                        Positioned(
                          top: 100,
                          right: 40,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                context.go('/settings/edit-profile');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.tertiary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.tertiary.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: AppTheme.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

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

class _ProfileDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
