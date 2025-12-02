import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../main.dart';
import 'notificationScreen.dart';

class FirebaseNotification {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// تهيئة الإشعارات
  Future<String?> initNotifications() async {
    // طلب إذن الإشعارات
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint("User declined notifications");
      return "null User declined notifications";
    }

    // iOS: الانتظار لوصول APNs token قبل استدعاء getToken()
    if (Platform.isIOS) {
      // الاستماع للـ FCM token الذي يضمن وصول APNs token
      final tokenCompleter = Completer<String?>();
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint("FCM Token refreshed: $newToken");
        if (!tokenCompleter.isCompleted) tokenCompleter.complete(newToken);
      });

      // محاولة الحصول على التوكين الحالي
      String? token = await _messaging.getToken();
      if (token != null) {
        debugPrint("FCM Token: $token");
        tokenCompleter.complete(token);
      }

      return tokenCompleter.future;
    }

    // Android: مباشرة الحصول على FCM token
    try {
      String? token = await _messaging.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting FCM Token: $e");
      return "null of token ";
    }
  }

  /// الاستماع لتحديث الـ token لاحقًا
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token refreshed: $newToken");
    });
  }

  /// التعامل مع الإشعارات عند فتح التطبيق
  void handleBackgroundMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    _messaging.getInitialMessage().then(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }
}
