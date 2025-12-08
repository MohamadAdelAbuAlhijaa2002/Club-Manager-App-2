import 'dart:async';
import 'dart:io';

import 'package:club_app_organizations_section/main.dart';
import 'package:club_app_organizations_section/appScreenOrganizations/notification/notificationScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class FirebaseNotification {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<String?> initNotifications() async {
    String? token ;
    if (Platform.isIOS) {
       token = await _getTokenSafely();
    }

    // طلب صلاحيات الإشعارات

    if(Platform.isAndroid) {
      await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
      await _createNotificationChannel();
    }

    // إعداد Local Notification
    final initSettings = _getNotificationInitializationSettings();
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) {
        navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
      },
    );

    // الحصول على FCM Token
    token ??= await _firebaseMessaging.getToken();
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

  // --------------------- فصل الإعدادات ---------------------
  // إعدادات Android
  AndroidInitializationSettings _getAndroidSettings() {
    return const AndroidInitializationSettings('@mipmap/ic_launcher');
  }

  // إعدادات iOS
  DarwinInitializationSettings _getIOSSettings() {
    return const DarwinInitializationSettings();
  }

  // الإعدادات المشتركة لكلا النظامين
  InitializationSettings _getNotificationInitializationSettings() {
    return InitializationSettings(
      android: _getAndroidSettings(),
      iOS: _getIOSSettings(),
    );
  }

  // --------------------- التعامل مع الخلفية ---------------------
  void _handleBackgroundNotifications() {
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(NotificationScreen.routeName);
  }

  Future<void> _showLocalNotification(String title, String body) async {
    // مسار الصورة المؤقت على الجهاز
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = '${tempDir.path}/icon.png';

    // نسخ الصورة من assets إلى temp path
    final byteData = await rootBundle.load('lib/assets/icon.png');
    final file = File(tempPath);
    await file.writeAsBytes(byteData.buffer.asUint8List());

    // Android
    final bigPictureStyle = BigPictureStyleInformation(
      FilePathAndroidBitmap(tempPath),
      contentTitle: title,
      summaryText: body,
    );

    final androidDetails = AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyle,
    );

    // iOS
    final iosDetails = DarwinNotificationDetails(
      attachments: [DarwinNotificationAttachment(tempPath)],
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
  // --------------------- APNs Token iOS ---------------------
  Future<String> _getTokenSafely() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // محاولة جلب APNs token
      Completer<String?> tokenCompleter = Completer<String?>();
      String? apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        print("✅ APNs Token جاهز: $apnsToken");
        tokenCompleter.complete(apnsToken);
      } else {
        print("⏳ انتظار APNs token...");
        await Future.delayed(const Duration(seconds: 3));
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          print("✅ APNs Token بعد delay: $apnsToken");
          tokenCompleter.complete(apnsToken);
        } else {
          tokenCompleter.complete(null);
        }
      }

      // الحصول على FCM token
      String? fcmToken = await messaging.getToken();
      print("✅ FCM Token: $fcmToken");
      if (fcmToken == null) return "token is null";
      return fcmToken;
    } catch (e) {
      print("❌ خطأ: $e");
      return "$e";
    }
  }




  Future<void> _createNotificationChannel() async {
    final androidChannel = AndroidNotificationChannel(
      'fcm_channel',
      'FCM Notifications',
      description: 'Channel for FCM notifications',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

}
