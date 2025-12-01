import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    let channelName: String = "PushNotificationChannel"
    var deviceToken: String = ""

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let pushNotificationChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self // لا حاجة لتصريح البروتوكول هنا
        }

        pushNotificationChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "requestNotificationPermissions":
                self?.requestNotificationPermissions(result: result)
            case "registerForPushNotifications":
                self?.registerForPushNotifications(application: application, result: result)
            case "retrieveDeviceToken":
                result(self?.deviceToken)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceTokenData: Data) {
        self.deviceToken = deviceTokenData.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(self.deviceToken)")
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceTokenData)
    }
}

