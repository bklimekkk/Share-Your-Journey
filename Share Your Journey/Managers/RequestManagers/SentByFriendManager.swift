//
//  SendByFriendManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 19/02/2023.
//

import Foundation
import Firebase
import SwiftUI

struct SentByFriendManager {

    @Binding var list: [SingleJourney]
    /**
     Function is responsible for populating the array with journeys sent by friend.
     */
    func populateFriendsJourneys(uid: String, completion: @escaping () -> Void) {
        let path = "\(FirestorePaths.getFriends(uid: uid))/\(Auth.auth().currentUser?.uid ?? "")/journeys"
        Firestore.firestore().collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let receivedJourneys = querySnapshot!.documents
                for journey in receivedJourneys {
                    if !self.list.map({return $0.name}).contains(journey.documentID) && !(journey.get("deletedJourney") as? Bool ?? false) {
                        self.list.append(SingleJourney(uid: uid,
                                                               name: journey.documentID,
                                                               place: journey.get("place") as? String ?? "",
                                                               date: (journey.get("date") as? Timestamp)?.dateValue() ?? Date.now,
                                                               operationDate: (journey.get("operationDate") as? Timestamp)?.dateValue() ?? Date.now,
                                                               numberOfPhotos: journey.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
                self.list.removeAll(where: {!receivedJourneys.map({return $0.documentID}).contains($0.name)})
            }
        }
    }
}
