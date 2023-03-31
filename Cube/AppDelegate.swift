//
//  AppDelegate.swift
//

import UIKit
import Firebase

// @main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application (_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Allo.i ("application / didFinishLaunchingWithOptions", String (describing: self))
        
        FirebaseApp.configure ()

        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self;
        // [END set_messaging_delegate]

        // [START register_for_notifications]
        if #available(iOS 10.0, *)
        {
            UNUserNotificationCenter.current().delegate = self;
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound];
            UNUserNotificationCenter.current().requestAuthorization (options: authOptions, completionHandler: {_, _ in })
        }
        else
        {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings (types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings (settings)
        }
        application.registerForRemoteNotifications ()
        // [END register_for_notifications]

        return true;
    }

    // MARK: UISceneSession Lifecycle

    func application (_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.

        Allo.i ("application / configurationForConnecting", String (describing: self))

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application (_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.

        Allo.i ("application / didDiscardSceneSessions", String (describing: self))
    }

    // MARK: Firebase Methods

    // [START receive_message]
    func application (_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Allo.i ("application / didReceiveRemoteNotification", String (describing: self))
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)

        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    }

    func application (_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Allo.i ("application / didReceiveRemoteNotification \(userInfo)", String (describing: self))

        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo [gcmMessageIDKey] {
            print ("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

      completionHandler (UIBackgroundFetchResult.newData)
    }
    // [END receive_message]

    func application (_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Allo.i ("application / didFailToRegisterForRemoteNotificationsWithError \(error.localizedDescription)", String (describing: self))
        // print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

        // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
        // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
        // the FCM registration token.
    func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Allo.i ("application / didRegisterForRemoteNotificationsWithDeviceToken \(deviceToken)", String (describing: self))
        // print("APNs token retrieved: \(deviceToken)")

        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate
{

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter (_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Allo.i ("userNotificationCenter / willPresent / withCompletionHandler", String (describing: self))

        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print message ID.
        if let messageID = userInfo [gcmMessageIDKey] {
            print ("Message ID: \(messageID)")
        }

        // Print full message.
        print (userInfo)

        if let userInfo = notification.request.content.userInfo as? [String: Any] {
            // 푸시 알림 기본 데이터
            if let aps = userInfo ["aps"] as? [AnyHashable: Any],
               let alert = aps ["alert"] as? [AnyHashable: Any],
               let title = alert ["title"] as? String,
               let message = alert ["body"] as? String {
                let optionalLink : String? = userInfo ["link"] as? String
                Allo.i ("Check [\(title)][\(message)][\(String (describing: optionalLink))]")
            }
        }

        // Change this to your preferred presentation option
        completionHandler ([[.alert, .sound]])
    }

    func userNotificationCenter (_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse,
                                  withCompletionHandler completionHandler: @escaping () -> Void) {
        Allo.i ("userNotificationCenter / didReceive / withCompletionHandler", String (describing: self))

        let userInfo = response.notification.request.content.userInfo
        
        // Print message ID.
        if let messageID = userInfo [gcmMessageIDKey] {
          print ("Message ID: \(messageID)")
        }

        // Print full message.
        print (userInfo)

        if let keyWindow = UIApplication.shared.windows.filter ({ $0.isKeyWindow }).first,
           let controller = keyWindow.rootViewController as? ViewController {
            controller.rotateNotification (userInfo)
        }

        completionHandler ()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate
{
    // [START refresh_token]
    func messaging (_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Allo.i ("messaging / didReceiveRegistrationToken \(String (describing: fcmToken))", String (describing: self))
        // print("Firebase registration token: \(fcmToken)")

        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post (name: Notification.Name ("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
}
