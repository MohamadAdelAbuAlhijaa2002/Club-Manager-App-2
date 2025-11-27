import 'package:club_app_organizations_section/appScreenOrganizations/notification/notificationScreen.dart';
import 'package:club_app_organizations_section/saveToken/saveToken.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'appScreenOrganizations/homePage/homePage.dart';
import 'appScreenOrganizations/loginScren/loginScreen.dart';
import 'appScreenOrganizations/notification/notification.dart';
import 'appScreenOrganizations/sectionsScreen/sectionsScreen.dart';
import 'bloc/Cubit.dart';
import 'bloc/states.dart';
//1.1.0
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;


  final firebaseNotification = FirebaseNotification();
  await firebaseNotification.initNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
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
    checkToken();

    // استدعاء بعد أن يبنى الـ widget tree
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   CubitApp.get(context).checkTokenData();
    // });
  }

  Future<void> checkToken() async {
    String? token = await getTokenOrganization();
    setState(() {
      _token = token;
      _loading = false;
    });
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
                  : _token == null
                  ? LoginScreen()
                  : cubit.dataCheckToken ? SectionScreen() : LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}

