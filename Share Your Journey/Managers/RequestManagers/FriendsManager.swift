//
//  FriendsManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 19/02/2023.
//

import Foundation
import Firebase
import SwiftUI

struct FriendsManager {
    @Binding var friendsSet: FriendsSet
    /**
     Function is responsible for pulling data about user's friends from the server and populating the friends array with it.
     */
    func populateFriends(completion: @escaping() -> Void) {

        //This block of code ensures that users that are currently logged in, will see their own friends list (even after logging out).
        let currentUID = Auth.auth().currentUser?.uid ?? ""
        if self.friendsSet.ownUID != currentUID {
            self.friendsSet.friendsList = []
            self.friendsSet.ownUID = currentUID
        }

        //Data is pulled out of the appropriate collection in firestore database and array is populated with it.
        Firestore.firestore().collection(FirestorePaths.getFriends(uid: currentUID)).getDocuments { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for friend in querySnapshot!.documents {
                    if friend.documentID != currentUID && !self.friendsSet.friendsList.map({$0.uid}).contains(friend.documentID) {
                        self.friendsSet.friendsList.append(Person(nickname: friend.get("nickname") as? String ?? "", uid: friend.documentID))
                    }
                }
            }
        }
    }
}
