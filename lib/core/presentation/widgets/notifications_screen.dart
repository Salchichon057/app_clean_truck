import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/auth/presentation/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
        actions: [
          notificationsAsync.when(
            data: (notifications) => notifications.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Eliminar todo',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Eliminar todas las notificaciones',
                          ),
                          content: const Text(
                            '¿Estás seguro de que deseas eliminar todas las notificaciones?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Eliminar todo'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final user = ref.read(currentUserProvider);
                        if (user != null) {
                          await ref
                              .read(notificationViewModelProvider.notifier)
                              .deleteAll(user.uid);
                        }
                      }
                    },
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) => notifications.isEmpty
            ? const Center(child: Text('No tienes notificaciones.'))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final user = ref.read(currentUserProvider);
                  return Dismissible(
                    key: Key(notif.uid),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      if (user != null) {
                        await ref
                            .read(notificationViewModelProvider.notifier)
                            .deleteNotification(user.uid, notif.uid);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificación eliminada')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Icon(
                          notif.read
                              ? Icons.notifications
                              : Icons.notifications_active,
                          color: notif.read ? Colors.grey : Colors.blue,
                        ),
                        title: Text(notif.message),
                        subtitle: Text(
                          notif.timestamp.toDate().toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!notif.read)
                              IconButton(
                                icon: const Icon(Icons.mark_email_read),
                                tooltip: 'Marcar como leída',
                                onPressed: () {
                                  if (user != null) {
                                    ref
                                        .read(
                                          notificationViewModelProvider
                                              .notifier,
                                        )
                                        .markAsRead(user.uid, notif.uid);
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Eliminar',
                              onPressed: () async {
                                if (user != null) {
                                  await ref
                                      .read(
                                        notificationViewModelProvider.notifier,
                                      )
                                      .deleteNotification(user.uid, notif.uid);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
