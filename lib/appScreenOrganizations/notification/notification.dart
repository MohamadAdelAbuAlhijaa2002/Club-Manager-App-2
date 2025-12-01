import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../main.dart';
import 'notificationScreen.dart';


class FirebaseNotification {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();



  // Source - https://stackoverflow.com/q
// Posted by Patrick
// Retrieved 2025-12-01, License - CC BY-SA 4.0

   initNotifications() async {
     String? apnsToken ;
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    final permissionRequest = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (permissionRequest.authorizationStatus == AuthorizationStatus.authorized) {

      if (Platform.isIOS) {
         apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken != null) {
          debugPrint("APNS Token: $apnsToken");
          apnsToken = await FirebaseMessaging.instance.getToken();
          debugPrint("FCM Token: $apnsToken");
        } else {
          debugPrint("APNS Token not available, waiting ...");

          await Future<void>.delayed(
            const Duration(
              seconds: 3,
            ),
          );

          apnsToken = await FirebaseMessaging.instance.getAPNSToken();

          if (apnsToken != null) {
            debugPrint("APNS Token: $apnsToken");
            apnsToken = await FirebaseMessaging.instance.getToken();
            debugPrint("FCM Token: $apnsToken");
          } else {
            debugPrint("APNS Token not available, trying to get FCM token anyway ...");

            try {
              apnsToken = await FirebaseMessaging.instance.getToken();
            } catch (err) {
              debugPrint("FCM Token not available ($err)");
            }
          }
        }

      } else {
        apnsToken = await FirebaseMessaging.instance.getToken();
        debugPrint("FCM Token: $apnsToken");
      }
    } else {
      debugPrint("Notifications not authorized");
    }



    return apnsToken ;
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
