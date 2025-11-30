import 'package:club_app_organizations_section/main.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/notification/notificationScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotification {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<String?> initNotifications() async {
    // طلب صلاحيات الإشعارات
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // إعداد Local Notification
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) {
        navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
      },
    );

    // الحصول على FCM Token للمنصتين
    String? token = await _firebaseMessaging.getToken();
     print("FCM Token: $token");


    // التعامل مع الرسائل في الخلفية
    _handleBackgroundNotifications();

    // استقبال الرسائل أثناء تشغيل التطبيق وعرض إشعار محلي
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',
        );
      }
    });

    return token;
  }

  void _handleBackgroundNotifications() {
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}
