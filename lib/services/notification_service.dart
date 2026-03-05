import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
        'FCM permission: ${settings.authorizationStatus}');

    // Get token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');

    // Subscribe to default topics
    await _messaging.subscribeToTopic('general');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
          'Foreground message: ${message.notification?.title}');
    });

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed: $newToken');
    });
  }

  Future<void> subscribeToUserTopics(String userId) async {
    await _messaging.subscribeToTopic('user_$userId');
  }

  Future<void> unsubscribeFromUserTopics(String userId) async {
    await _messaging.unsubscribeFromTopic('user_$userId');
  }

  Future<String?> getToken() => _messaging.getToken();
}
