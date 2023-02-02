//
//  AccountManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 26/01/2023.
//

import Foundation
import Firebase

struct AccountManager {
    static func getNickname(uid: String, completion: @escaping(String) -> Void) {
        let nicknameRef = Firestore.firestore()
            .collection(FirestorePaths.users)
            .document(Auth.auth().currentUser?.uid ?? UIStrings.emptyString)
        nicknameRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(document.get("nickname") as? String ?? UIStrings.emptyString)
            } else {
                print(error?.localizedDescription)
            }
        }
    }

    static func checkNicknameUniqueness(nickname: String, completion: @escaping(Bool) -> Void) {
        Firestore.firestore().collection(FirestorePaths.users).getDocuments { querySnapshot, error in
            if error != nil {
                completion(false)
            } else {
                var uniqueNicknames = Set(querySnapshot!.documents.map({$0.get("nickname") as? String ?? UIStrings.emptyString}))
                uniqueNicknames.insert(nickname)
                completion(uniqueNicknames.count == querySnapshot!.documents.count + 1)
            }
        }
    }

    static func changeNickname(newNickname: String, completion: @escaping() -> Void) {
        let uid = Auth.auth().currentUser?.uid ?? UIStrings.emptyString
        Firestore.firestore().collection(FirestorePaths.users).document(uid).updateData(["nickname": newNickname])
        Firestore.firestore().collection(FirestorePaths.getFriends(uid: uid)).getDocuments { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? UIStrings.emptyString)
            } else {
                let documents = snapshot!.documents.filter({$0.documentID != uid})
                for friend in documents {
                        Firestore.firestore().collection(FirestorePaths.getFriends(uid: friend.documentID)).document(uid).updateData(["nickname": newNickname])
                }
            }


            // TODO: -   get requests
            UserDefaults.standard.set(newNickname, forKey: "nickname")
            completion()
        }
    }
}
