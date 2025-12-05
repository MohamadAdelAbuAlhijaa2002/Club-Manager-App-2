import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';
import 'notificationScreen.dart';

class FirebaseNotification {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Flutter Local Notifications
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  bool _isNotificationsInitialized = false;

  /// تهيئة الإشعارات والحصول على FCM / APNs Token
  Future<String> initNotifications() async {
    try {
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
        // تفعيل عرض إشعارات foreground على iOS
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await _initLocalNotifications();

      // الاستماع لتحديث الـ token لاحقًا
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint("🔄 Token refreshed: $newToken");
      });

      // APNs token على iOS
      if (Platform.isIOS) {
        String? apnsToken;
        int attempts = 0;
        final completer = Completer<String?>();
        void tokenListener(String? token) {
          if (token != null && !completer.isCompleted) {
            debugPrint("✅ APNs token received: $token");
            completer.complete(token);
          }
        }

        final sub = _messaging.onTokenRefresh.listen(tokenListener);

        String? token = await _messaging.getAPNSToken();
        if (token != null) {
          sub.cancel();
          return token;
        }

        try {
          token = await completer.future.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint("⚠️ APNs token not received after 30 seconds");
              return null;
            },
          );
        } finally {
          sub.cancel();
        }

        if (token == null) return "APNs token not received";
        return token;

      }

      // FCM token
      String? token = await _messaging.getToken();
      if (token == null) {
        debugPrint("⚠️ FCM token is null");
        return "Token not available: FCM token is null";
      }
      debugPrint("✅ FCM Token: $token");
      return token;

    } catch (e) {
      debugPrint("❌ Error getting token: $e");
      return "Token not available: Error $e";
    }
  }

  /// إعداد Flutter Local Notifications
  Future<void> _initLocalNotifications() async {
    if (_isNotificationsInitialized) return;

    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (!kIsWeb) {
      // إنشاء قناة إشعارات على Android
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _isNotificationsInitialized = true;
  }

  /// التعامل مع تحديث الـ token لاحقًا
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("🔄 Token refreshed: $newToken");
    });
  }

  /// التعامل مع الإشعارات عند فتح التطبيق
  void handleBackgroundMessages() {
    FirebaseMessaging.onMessage.listen(_showNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    _messaging.getInitialMessage().then(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }

  /// عرض إشعار باستخدام Flutter Local Notifications
  void _showNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: android != null
              ? AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'lib/assets/icon.png',
          )
              : null,
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
