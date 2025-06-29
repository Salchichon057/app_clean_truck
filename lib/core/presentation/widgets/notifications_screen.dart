import 'package:comaslimpio/features/auth/presentation/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final notificationViewModel = ref.watch(
      notificationViewModelProvider.notifier,
    );
    final notificationState = ref.watch(notificationViewModelProvider);

    // Carga las notificaciones al entrar
    if (user != null &&
        notificationState.notifications.isEmpty &&
        !notificationState.isLoading) {
      notificationViewModel.loadNotificationsForUser(user.uid);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Eliminar todo',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar todas las notificaciones'),
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
                if (confirm == true && user != null) {
                  await notificationViewModel.deleteAll(user.uid);
                }
              },
            ),
        ],
      ),
      body: notificationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationState.notifications.isEmpty
          ? const Center(child: Text('No tienes notificaciones.'))
          : ListView.builder(
              itemCount: notificationState.notifications.length,
              itemBuilder: (context, index) {
                final notif = notificationState.notifications[index];
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
                      await notificationViewModel.deleteNotification(
                        user.uid,
                        notif.uid,
                      );
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
                                notificationViewModel.markAsRead(
                                  user!.uid,
                                  notif.uid,
                                );
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              await notificationViewModel.deleteNotification(
                                user!.uid,
                                notif.uid,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
