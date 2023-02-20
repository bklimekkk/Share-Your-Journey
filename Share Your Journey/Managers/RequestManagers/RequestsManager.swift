//
//  RequestsManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 19/02/2023.
//

import Foundation
import Firebase
import SwiftUI

struct RequestsManager {

    @Binding var requestsSet: RequestsSet

    /**
     Function is responsible for searching server in order to return user list of requests sent to them.
     */
    func populateRequests(completion: @escaping() -> Void) {

        //Variable controls which user is currently logged in into the application.
        let currentUID = Auth.auth().currentUser?.uid ?? ""

        //Users can change account while being on the same phone. This statement detects it and refreshes the array accordingly.
        if self.requestsSet.ownUID != currentUID {
            self.requestsSet.requestsList = []
            self.requestsSet.ownUID = currentUID
        }

        //Program searches through requests collection in Firebase in order to fetch user's requests.
        Firestore.firestore().collection(FirestorePaths.getRequests(uid: currentUID)).getDocuments { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for request in querySnapshot!.documents {
                    if request.documentID != currentUID && !self.requestsSet.requestsList.map({$0.uid}).contains(request.documentID) {
                        self.requestsSet.requestsList.append(Person(nickname: request.get("nickname") as? String ?? "", uid: request.documentID))
                    }
                }
            }
        }
    }

    /**
     Function is responsible for removing requests picked by user.
     */
    func removeRequest(request: Person) {
        //Chosen request is deleted from Firestore database.
        Firestore.firestore().collection(FirestorePaths.getRequests(uid: Auth.auth().currentUser?.uid ?? "")).document(request.uid).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        Firestore.firestore().collection("users/\(request.uid)/sentRequests").document(Auth.auth().currentUser?.uid ?? "").delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        self.requestsSet.requestsList.removeAll(where: {$0.uid == request.uid})
    }

    /**
     Function responsible for accepting request sent to the user.
     */
    func acceptRequest(request: Person) {
        AccountManager.getNickname(uid: request.uid) { nickname in
            //UID of account from which the request was sent from, is added to friends collection in Firestore database.
            Firestore.firestore().document("\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(request.uid)").setData([
                "uid" : request.uid,
                "nickname" : nickname
            ])
        }

        //Program also needs to take care about adding user to their friend's "friends" collection.
        Firestore.firestore().document("\(FirestorePaths.getFriends(uid: request.uid))/\(Auth.auth().currentUser?.uid ?? "")").setData([
            "uid" : Auth.auth().currentUser?.uid ?? "",
            "nickname" : UserDefaults.standard.string(forKey: "nickname") ?? ""
        ])

        //After request accepted, it needs to be deleted from requests array automatically.
        self.removeRequest(request: request)
    }
}
