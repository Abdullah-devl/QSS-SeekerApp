// lib/features/notifications/viewmodels/notification_view_model.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../repositories/notification_repository.dart';
import '../models/notification_model.dart';

enum NotificationFilter { all, read, unread }

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationViewModel(this._repository) {
    fetchNotifications();
    
    // الاستماع للإشعارات القادمة في المقدمة لتحديث القائمة تلقائياً
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      fetchNotifications();
    });
  }

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  NotificationFilter _currentFilter = NotificationFilter.all;

  NotificationFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get notifications {
    switch (_currentFilter) {
      case NotificationFilter.read:
        return _notifications.where((n) => n.isRead).toList();
      case NotificationFilter.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.all:
      default:
        return _notifications;
    }
  }

  void setFilter(NotificationFilter filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      notifyListeners();
    }
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repository.fetchNotifications();
    } catch (e) {
      // Handle error if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      await _repository.markAsRead(id);
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        data: _notifications[index].data,
        isRead: true,
        createdAt: _notifications[index].createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _notifications = _notifications.map((n) => NotificationModel(
      id: n.id,
      title: n.title,
      message: n.message,
      type: n.type,
      data: n.data,
      isRead: true,
      createdAt: n.createdAt,
    )).toList();
    notifyListeners();
  }
}
