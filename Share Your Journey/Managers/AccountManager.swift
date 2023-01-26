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
            .collection(FirestorePaths.getUsers())
            .document(Auth.auth().currentUser?.uid ?? UIStrings.emptyString)
        nicknameRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(document.get("nickname") as? String ?? UIStrings.emptyString)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
}
