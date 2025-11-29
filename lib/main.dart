import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // تم إنشاؤه بواسطة FlutterFire CLI
import 'appScreenOrganizations/loginScren/loginScreen.dart';
import 'appScreenOrganizations/notification/notificationScreen.dart';
import 'appScreenOrganizations/sectionsScreen/sectionsScreen.dart';
import 'bloc/Cubit.dart';
import 'bloc/states.dart';
import 'saveToken/saveToken.dart';
import 'appScreenOrganizations/notification/notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase بشكل صحيح لكل منصة
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. تهيئة Crashlytics بعد Firebase
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 3. إعداد Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final firebaseNotification = FirebaseNotification();
  try {
    await firebaseNotification.initNotifications();
  } catch (e, st) {
    print('Notification init error: $e');
    FirebaseCrashlytics.instance.recordError(e, st);
  }

  // 4. تشغيل التطبيق
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

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    try {
      String? token = await getTokenOrganization();
      setState(() {
        _token = token;
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
          final cubit = CubitApp.get(context);

          return ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (_, __) => MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              locale: const Locale('ar'),
              routes: {
                NotificationScreen.routeName: (_) => NotificationScreen(),
              },
              home: _loading
                  ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
                  : (_token == null || cubit.dataCheckToken != true)
                  ? LoginScreen()
                  : SectionScreen(),

            ),
          );
        },
      ),
    );
  }
}
