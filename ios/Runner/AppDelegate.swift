import UIKit
import Flutter
import GoogleMaps
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initialize Firebase if not already initialized
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // Set up notifications delegate for iOS 10+
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }

        // [v5 iOS 27 phone-auth crash fix]
        // Info.plist has FirebaseAppDelegateProxyEnabled = false, which means
        // Flutter's automatic Firebase messaging swizzling is disabled. For
        // Firebase phone auth to work on iOS (especially iPad where there's
        // no SIM and the silent push notification path is mandatory), we MUST
        // manually bridge the APNs device token to the Messaging delegate.
        // Without this bridge, `verifyPhoneNumber` fails with
        // `auth/missing-apns-token` and the verificationFailed callback fires
        // — on iPad/iOS 27 this previously led to a crash inside the
        // Overlay toast path. Bridging the APNs token lets Firebase complete
        // the silent push and (when applicable) auto-retrieve the SMS code.
        FirebaseMessaging.delegate = self

        //<!--TODO REPLACE IOS APP NAME HERE-->
        // Initialize Google Maps
        GMSServices.provideAPIKey("PLACE_IOS_MAP_KEY_HERE")

        // Register Flutter plugins only once
        let registry = self as FlutterPluginRegistry
        GeneratedPluginRegistrant.register(with: registry)

        // Register for remote notifications (required for Firebase phone auth
        // silent push on iOS 27 / iPadOS 27).
        application.registerForRemoteNotifications()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // [v5] Forward the APNs device token to Firebase so that phone-auth
    // silent push notifications can be delivered.
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    // [v5] Log APNs registration failure so we can debug — but don't crash.
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        debugPrint("Failed to register for remote notifications: \(error.localizedDescription)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}

// [v5] Conform to MessagingDelegate so Firebase can receive APNs tokens
// and remote-notification payloads even with the app proxy disabled.
extension AppDelegate: MessagingDelegate {
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        // Forward the FCM token to the rest of the app via NotificationCenter
        // so the Flutter side can pick it up if needed.
        let dataDict: [String: String?] = ["token": fcmToken]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}
