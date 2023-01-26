//
//  Share_Your_JourneyApp.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 07/02/2022.
//

import SwiftUI
import RevenueCat
import Firebase
import FirebaseMessaging
import NotificationCenter

@main
struct Share_Your_JourneyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var journeyDataManager = JourneyDataManager()
    var body: some Scene {
        WindowGroup {
            TabsView()
                .environment(\.managedObjectContext, journeyDataManager.journeyContainer.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.messagge_id"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Babcia na zawsze")
        UITabBar.appearance().backgroundColor = Colors.tabViewColor
        self.setupRevenueCat()
        FirebaseApp.configure()

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        //Do something with message data here
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        return UIBackgroundFetchResult.newData
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }

    func setupRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Links.revenueCatAPIKey)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        print(dataDict)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        // Print full message.

        if let messageID = userInfo[self.gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        print(userInfo)

        // Change this to your preferred presentation option
        return [[.banner, .badge, .sound]]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let content = response.notification.request.content
        let title = content.title
        let nickname = content.userInfo["nickname"] as? String ?? UIStrings.emptyString
        NotificationSetup.shared.notificationType = title == UIStrings.friendInvitationNotificationTitle ? .invitation : .journey
        NotificationSetup.shared.sender = NotificationSetup.shared.notificationType == .journey ? nickname : UIStrings.emptyString
        print(nickname)
    }
}
