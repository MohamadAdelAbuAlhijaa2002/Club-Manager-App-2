import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../main.dart';
import 'notificationScreen.dart';


class FirebaseNotification {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<String?> initNotifications() async {
    String? token;

    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iOSInit);

    await _flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (payload) {
          navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
        });

      token = await _firebaseMessaging.getToken();
      print("iOS FCM Token: $token");
      if(token == null) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        print("APNs Token (iOS): $apnsToken");
        token = apnsToken ;
      }

    _listenTokenRefresh();
    _handleBackgroundNotifications();

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        _showLocalNotification(
            message.notification!.title ?? '', message.notification!.body ?? '');
      }
    });

    return token;
  }

  void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("FCM Token refreshed: $newToken");
    });
  }

  void _handleBackgroundNotifications() {
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }

  Future _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
        'fcm_channel', 'FCM Notifications',
        importance: Importance.max, priority: Priority.high);
    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails =
    NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }
}
