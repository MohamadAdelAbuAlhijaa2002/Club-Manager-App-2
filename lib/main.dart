import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'bloc/Cubit.dart';
import 'bloc/states.dart';
import 'saveToken/saveToken.dart';
import 'appScreenOrganizations/loginScren/loginScreen.dart';
import 'appScreenOrganizations/sectionsScreen/sectionsScreen.dart';
import 'appScreenOrganizations/notification/notificationScreen.dart';
import 'appScreenOrganizations/notification/notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("🔔 Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;
  bool _loading = true;

  final firebaseNotification = FirebaseNotification();

  @override
  void initState() {
    super.initState();

    initNotificationsAndToken();
    initApp();
  }

  /// طلب الإشعارات وانتظار FCM token قبل الاستخدام
  Future<void> initNotificationsAndToken() async {
    String? token = await firebaseNotification.initNotifications();
    debugPrint("Initialized FCM token: $token");
    setState(() {
      _token = token;
    });

    firebaseNotification.listenTokenRefresh();
    firebaseNotification.handleBackgroundMessages();
  }

  Future<void> initApp() async {
    try {
      String? savedToken = await getTokenOrganization();
      setState(() {
        _token ??= savedToken; // استخدم توكن FCM إذا لم يصل بعد
        _loading = false;
      });
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st);
      setState(() {
        _token = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CubitApp()..checkTokenData(),
      child: BlocConsumer<CubitApp, StatesApp>(
        listener: (context, state) {},
        builder: (context, state) {
          if (_loading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.deepPurple),
                ),
              ),
            );
          }

          return ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, __) => MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar'),
              theme: ThemeData(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  },
                ),
              ),
              routes: {
                NotificationScreen.routeName: (_) => NotificationScreen(),
              },
              home: (_token == null) ? LoginScreen() : SectionScreen(),
            ),
          );
        },
      ),
    );
  }
}
