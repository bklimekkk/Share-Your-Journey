//
//  ChatManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 19/02/2023.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI

struct SentByYouManager {

    @Binding var list: [SingleJourney]
    /**
     Function is responsible for populating array with users' journeys with data from the server.
     */
    func populateYourJourneys(uid: String, completion: @escaping() -> Void) {
        let path = "\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(uid)/journeys"
        Firestore.firestore().collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for journey in querySnapshot!.documents {
                    //If conditions are met, journey's data is appended to the array.
                    if !self.list.map({return $0.name}).contains(journey.documentID) && !(journey.get("deletedJourney") as? Bool ?? false) {
                        self.list.append(SingleJourney(uid: Auth.auth().currentUser?.uid ?? "",
                                                            name: journey.documentID,
                                                            place: journey.get("place") as? String ?? "",
                                                            date: (journey.get("date") as? Timestamp)?.dateValue() ?? Date.now,
                                                            operationDate: (journey.get("operationDate") as? Timestamp)?.dateValue() ?? Date.now,
                                                            numberOfPhotos: journey.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
            }
        }
    }

    /**
     Function is responsible for searching entire database (appropriate collections) in order to find out if journey's data still exist somewhere in the server.
     */
    func checkForDuplicate(name: String, uid: String, completion: @escaping(Bool) -> Void) {
        let friendsPath = FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? "")
        Firestore.firestore().collection(friendsPath).getDocuments { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let documents = snapshot!.documents.filter({$0.documentID != uid})
                if documents.isEmpty {
                    completion(true)
                } else {
                    for friend in documents {
                        Firestore.firestore().collection("\(friendsPath)/\(friend.documentID)/journeys").getDocuments { journeysSnapshot, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                if journeysSnapshot!.documents.first(where: {$0.documentID == name}) != nil {
                                    completion(false)
                                } else {
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     Function is responsible for deleting journey from list of journeys sent by user to particular friend.
     */
    func deleteJourneyFromDatabase(name: String, uid: String) {
        let yourUID = Auth.auth().currentUser?.uid ?? ""
        let path = "\(FirestorePaths.getFriends(uid: yourUID))/\(uid)/journeys"

        //Before collection is deleted, program needs to delete its all photos references (Collection needs to be empty in order to be deleted eternally).
        Firestore.firestore().collection("\(path)/\(name)/photos").getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                querySnapshot!.documents.forEach { document in
                    document.reference.delete()
                }
            }
        }
        Firestore.firestore().collection(path).document(name).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }

    /**
     Function is responsible for deleting journey's photos from storage.
     */
    func deleteJourneyFromStorage(journey: SingleJourney) {

        //Each photo is deleted separately.
        for photoNumber in 0...journey.numberOfPhotos {
            let deleteReference = Storage.storage().reference().child("\(Auth.auth().currentUser?.uid ?? "")/\(journey.name)/\(photoNumber)")
            deleteReference.delete { error in
                if error != nil {
                    print("Error while deleting journey from storage")
                } else {
                    print("Journey deleted from storage successfully")
                }
            }
        }
    }
}
