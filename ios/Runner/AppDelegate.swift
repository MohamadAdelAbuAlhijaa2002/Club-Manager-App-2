import UIKit
import Flutter
import Firebase
import FirebaseMessaging

@main // ✅ فقط هذا
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // تهيئة Firebase
    FirebaseApp.configure()

    // تسجيل الـ plugins
    GeneratedPluginRegistrant.register(with: self)

    // تسجيل الإشعارات البعيدة
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // الحصول على Device Token الخاص بـ APNs
  override func application(_ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
}
