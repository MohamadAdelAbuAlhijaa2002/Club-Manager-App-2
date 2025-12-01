import 'package:club_app_organizations_section/testNotfoication.dart';
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

// Screens
import 'appScreenOrganizations/loginScren/loginScreen.dart';
import 'appScreenOrganizations/sectionsScreen/sectionsScreen.dart';
import 'appScreenOrganizations/notification/notificationScreen.dart';
import 'appScreenOrganizations/notification/notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


/// ---------------------
/// Background Notification Handler (app terminated)
/// ---------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("🔔 Background message: ${message.messageId}");
}


/// ---------------------
/// MAIN FUNCTION
/// ---------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Background FCM Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseNotification().initNotifications();



  runApp(const MyApp());
}


/// ---------------------
/// MAIN APP WIDGET
/// ---------------------
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

    // تشغيل إشعارات Firebase بعد تشغيل الواجهة
    firebaseNotification.initNotifications();

    // تحميل توكن المستخدم (login)
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

          // ---------------------
          // شاشة تحميل أثناء قراءة التوكن
          // ---------------------
          if (_loading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    )),
              ),
            );
          }

          // ---------------------
          // التطبيق الرئيسي
          // ---------------------
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
              home: (_token == null)
                  ? LoginScreen()
                  : SectionScreen(),
            ),
          );
        },
      ),
    );
  }
}
