import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {

    FirebaseApp.configure() // ضروري

    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self



    application.registerForRemoteNotifications() // لتسجيل الجهاز لدى APNs

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
