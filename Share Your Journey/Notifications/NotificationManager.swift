//
//  NotificationManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 22/01/2023.
//  This file is created with help from https://iosapptemplates.com/blog/ios-development/push-notifications-firebase-swift-5 url

import Foundation

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications
class NotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        self.updateFirestorePushTokenIfNeeded()
    }
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            let usersRef = Firestore.firestore().collection("users").document(userID)
            usersRef.setData(["fcmToken": token], merge: true)
        }
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.updateFirestorePushTokenIfNeeded()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
}