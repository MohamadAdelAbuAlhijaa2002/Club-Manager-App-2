import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../main.dart';
import 'notificationScreen.dart';

class FirebaseNotification {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Flutter Local Notifications
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  bool _isNotificationsInitialized = false;

  /// تهيئة الإشعارات والحصول على FCM / APNs Token
  Future<String> initNotifications() async {
    try {
      // طلب صلاحيات iOS
      if (Platform.isIOS) {
        final settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          debugPrint("⚠️ User declined notifications");
          throw Exception("Token not available: User denied permission");
        }

        // عرض إشعارات foreground على iOS
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // تهيئة Local Notifications
    //  await _initLocalNotifications();

      // تفعيل FCM auto-init
     // await _messaging.setAutoInitEnabled(true);

      // الاستماع لتحديث الـ token مرة واحدة

      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint("🔄 Token refreshed: $newToken");
      });

      // الحصول على APNs token على iOS
      // if (Platform.isIOS) {
      //   // final apnsToken = await _getAPNSToken();
      //   // if (apnsToken == null) return "APNs token not received";
      //   // return apnsToken;
      //   Duration(seconds: 30);
      //   final apnsToken = await _messaging.getAPNSToken();
      //
      //   if(apnsToken != null) {
      //     Duration(seconds: 30);
      //     final apnsToken = await _messaging.getToken();
      //     return "$apnsToken" ;
      //   }
      //   else
      //     return "token is  : $apnsToken";
      //
      // }

     // tz.initializeTimeZones();
      // الحصول على FCM token على Android / Web

      if (Platform.isIOS) {
        await Future<void>.delayed(
          const Duration(
            seconds: 5,
          ),
        );
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          return apnsToken ;
        } else {
          await Future<void>.delayed(
            const Duration(
              seconds: 5,
            ),
          );
          apnsToken = await _messaging.getAPNSToken();

        }

        if (apnsToken != null) {
          return apnsToken ;
        }
      }

      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        debugPrint("⚠️ FCM token is null");
        throw Exception("Token not available: FCM token is null");

      }

      debugPrint("✅ FCM Token: $fcmToken");
      return fcmToken;
    } catch (e) {
      debugPrint("❌ Error getting token: $e");
      return "Token not available: Error $e";
    }
  }
















  /// الحصول على APNs token مع timeout
  Future<String?> _getAPNSToken() async {
    final completer = Completer<String?>();
    void tokenListener(String? token) {
      if (token != null && !completer.isCompleted) {
        debugPrint("✅ APNs token received: $token");
        completer.complete(token);
      }
    }

    final sub = _messaging.onTokenRefresh.listen(tokenListener);

    try {
      final token = await _messaging.getAPNSToken();
      if (token != null) return token;

      // انتظار APNs token حتى 30 ثانية
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint("⚠️ APNs token not received after 30 seconds");
          return null;
        },
      );
    } finally {
      sub.cancel();
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

  /// التعامل مع الإشعارات عند فتح التطبيق
  void handleNotifications() {
    // إشعارات foreground
    FirebaseMessaging.onMessage.listen(_showNotification);

    // عند فتح التطبيق من الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // عند فتح التطبيق من حالة terminated
    _messaging.getInitialMessage().then(_handleMessage);
  }

  /// عرض إشعار باستخدام Flutter Local Notifications
  void _showNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

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
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  /// التعامل مع النقر على الإشعار
  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }
}
