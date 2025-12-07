import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase init error: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APNs Token Display',
      home: TokenScreen(),
    );
  }
}

class TokenScreen extends StatefulWidget {
  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getTokenSafely();
  }

  Future<void> _getTokenSafely() async {
    try {
      // ✅ انتظار APNs token بـ Completer
      Completer<String?> tokenCompleter = Completer<String?>();

      // جرب getAPNSToken أولاً
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        print("✅ APNs Token جاهز: $apnsToken");
        tokenCompleter.complete(apnsToken);
      } else {
        // ✅ Delay + retry
        print("⏳ انتظار APNs token...");
        await Future.delayed(Duration(seconds: 3));

        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          print("✅ APNs Token بعد delay: $apnsToken");
          tokenCompleter.complete(apnsToken);
        } else {
          tokenCompleter.complete(null);
        }
      }

      // ✅ الحصول على FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      setState(() {
        _token = fcmToken;
        _isLoading = false;
      });

      print("✅ FCM Token: $_token");

    } catch (e) {
      print("❌ خطأ: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Text("Token: ${_token ?? 'لا يوجد'}"),
    );
  }
}
