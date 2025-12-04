import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../main.dart';
import 'notificationScreen.dart';

class FirebaseNotification {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// تهيئة الإشعارات والحصول على FCM Token
  Future<String> initNotifications() async {
    try {
      // طلب إذن الإشعارات (iOS فقط)
      if (Platform.isIOS) {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          debugPrint("⚠️ User declined notifications");
          return "Token not available: User denied permission";
        }

        String? apnsToken = await  _messaging.getAPNSToken();
        debugPrint("APNs token: $apnsToken");

      }

      await Future<void>.delayed(
        const Duration(
          seconds: 5,
        ),
      );
      // الحصول على FCM token
      String? token = await _messaging.getToken();
      if (token == null) {
        debugPrint("⚠️ FCM token is null");
        return "Token not available: null";
      }

      debugPrint("✅ FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("❌ Error getting FCM Token: $e");
      return "Token not available: Error $e";
    }
  }

  /// الاستماع لتحديث الـ token لاحقًا
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("🔄 FCM Token refreshed: $newToken");
    });
  }

  /// التعامل مع الإشعارات عند فتح التطبيق
  void handleBackgroundMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    _messaging.getInitialMessage().then(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    // هنا استدعاء الشاشة الخاصة بالإشعار
     navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }
}
