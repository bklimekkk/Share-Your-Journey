//
//  RequestManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 19/02/2023.
//

import SwiftUI
import Foundation
import Firebase

struct JourneysManager {
    @Binding var list: [SingleJourney]

    /**
     Function is responsible for clearing array containing journeys, if user has changed.
     */
    func clearInvalidJourneys() {
        if self.list.count != 0 && self.list[0].uid != Auth.auth().currentUser?.uid {
            self.list = []
        }
    }

    /**
     Function is responsible for adding journeys to array, and refreshing it if needed.
     */
    func updateJourneys(completion: @escaping () -> Void) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let path = "\(FirestorePaths.getFriends(uid: uid))/\(uid)/journeys"

        Firestore.firestore().collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for journey in querySnapshot!.documents {
                    if !self.list.map({return $0.name}).contains(journey.documentID) && !(journey.get("deletedJourney") as? Bool ?? false) {
                        self.list.append(SingleJourney(uid: journey.get("uid") as? String ?? "",
                                                               name: journey.documentID, place: journey.get("place") as? String ?? "",
                                                               date: (journey.get("date") as? Timestamp)?
                            .dateValue() ?? Date(), numberOfPhotos: journey.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
            }
        }
    }
}
