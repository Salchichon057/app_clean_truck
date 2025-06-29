import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationState {
  final List<Notification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<Notification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationViewModel(this._repository) : super(NotificationState());

  Future<void> loadNotificationsForUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _repository.getNotificationsForUser(userId);
      final unreadCount = notifications.where((n) => !n.read).length;
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addNotification(String userId, Notification notification) async {
    try {
      await _repository.addNotification(userId, notification);
      await loadNotificationsForUser(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _repository.markNotificationAsRead(userId, notificationId);
      await loadNotificationsForUser(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = state.notifications.where((n) => !n.read);
      for (final notification in unreadNotifications) {
        await _repository.markNotificationAsRead(userId, notification.uid);
      }
      await loadNotificationsForUser(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _repository.deleteNotification(userId, notificationId);
      await loadNotificationsForUser(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteAll(String userId) async {
    try {
      await _repository.deleteAllNotifications(userId);
      await loadNotificationsForUser(userId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
