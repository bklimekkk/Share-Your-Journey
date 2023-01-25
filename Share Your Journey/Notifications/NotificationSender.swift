//
//  NotificationSender.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 23/01/2023.
//

import Foundation
import Firebase

import UIKit
class NotificationSender {
    static func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title,
                                                             "body" : body,
                                                             "sound": "default"
                                                            ],
                                           "priority": "high",
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(Links.messagingServerKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

    static func sendNotification(uid: String, title: String, body: String) {
        let targetRef = Firestore.firestore()
            .collection(FirestorePaths.getUsers())
            .document(uid)
        targetRef.getDocument { document, error in
            if let document = document, document.exists {
                let token = document.get("fcmToken") as? String ?? UIStrings.emptyString
                self.sendPushNotification(to: token, title: title, body: body)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}

class NotificationSetup: ObservableObject {
    static let shared = NotificationSetup()
    @Published var notificationType: NotificationType = .none
    @Published var sender: String? = ""
}
