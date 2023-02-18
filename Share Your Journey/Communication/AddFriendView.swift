//
//  AddFriendView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 14/02/2022.
//

import SwiftUI
import Firebase

//Struct is responsible for presenting user with functionality neccessary for inviting a new friend. 
struct AddFriendView: View {
    
    //Variable described in ChatView struct.
    @Binding var sheetIsPresented: Bool
    //Friend's details
    @State private var nickname = ""
    @State private var uid = ""
    //Variable's value justifies if application should present users with any message.
    @State private var showMessage: Bool = false
    @State private var errorMessage = ""
    //Variable is set to one of enum values from InvitationError.
    @State private var responseType = InvitationError.valid
    
    var body: some View {
        VStack {
            Text(UIStrings.addAFriend)
            TextField(UIStrings.enterFriendsNickname, text: self.$nickname)
                .font(.system(size: 20))
            Spacer()
            Button {
                self.getUIDFromNickname(nickname: self.nickname.trimmingCharacters(in: .whitespacesAndNewlines)) { uid in
                    self.uid = uid
                    // TODO: - check if nickname exists, or do it in the getUIDFromNickname function
                    //If statement is responsible for checking if users haven't entered their own nickname while inviting a friend.
                    if self.uid == Auth.auth().currentUser?.uid {
                        self.responseType = .yourNickname
                        self.showMessage = true
                        return
                    }
                    self.checkIfFriendSentRequest { pass in
                        if pass {
                            self.checkAgainstDuplicateRequests { pass in
                                if pass {
                                    self.checkIfNotFriends { pass in
                                        if pass {
                                            self.showMessage = true
                                        } else { return }
                                    }
                                } else { return }
                            }
                        } else { return }
                    }
                }
            } label: {
                ButtonView(buttonTitle: UIStrings.sendRequest)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .padding()
        .alert(isPresented: self.$showMessage) {
            //Depending on which error occurs, users are presented to relevant message.
            Alert (title: Text(self.responseType == .valid ? self.nickname : UIStrings.invitationError),
                   message: Text(self.responseType.rawValue),
                   primaryButton: .cancel(Text(responseType == .valid ? UIStrings.cancel : UIStrings.quit)) {
                if self.responseType == .valid {
                    self.showMessage = false
                } else {
                    self.showMessage = false
                    self.sheetIsPresented = false
                    self.responseType = .valid
                }
            },
                   secondaryButton: .default(Text(self.responseType == .valid ? UIStrings.invite : UIStrings.tryAgain)) {
                if self.responseType == .valid {
                    self.sendRequest()
                } else {
                    self.showMessage = false
                    self.responseType = .valid
                    self.nickname = ""
                }
            }
            )
        }
    }

    /**
     Function responsible for sending the request to user (pulating relevant 'requests' collection with relevant request data.
     */
    func sendRequest() {
        Firestore.firestore().document("\(FirestorePaths.getRequests(uid: self.uid))/\(Auth.auth().currentUser?.uid ?? "")").setData([
            "nickname": UserDefaults.standard.string(forKey: "nickname") ?? "",
            "deletedAccount": false
        ])
        Firestore.firestore().document("")
        self.showMessage = false
        self.sheetIsPresented = false
        HapticFeedback.heavyHapticFeedback()
        NotificationSender.sendNotification(myNickname: UserDefaults.standard.string(forKey: "nickname") ?? "",
                                            uid: self.uid,
                                            title: UIStrings.friendInvitationNotificationTitle,
                                            body: "\(UserDefaults.standard.string(forKey: "nickname") ?? "") just sent you a friend invitation")
    }

    func getUIDFromNickname(nickname: String, completion: @escaping(String) -> Void) {
        //If Statement is responsible for checking if users haven't omit entering data.
        if nickname == "" {
            self.responseType = .emptyField
            self.showMessage = true
            return
        }
        Firestore.firestore().collection(FirestorePaths.users).getDocuments() { snapshot, error in
            if error != nil {
                self.showMessage = true
                self.errorMessage = error?.localizedDescription ?? ""
            } else {
                if let uid = snapshot!.documents.first(where: {$0.get("nickname") as? String ?? "" == nickname}) {
                    completion(uid.documentID)
                } else {
                    self.responseType = .noAccount
                    self.showMessage = true
                    return
                }
            }
        }
    }

    func checkIfFriendSentRequest(completion: @escaping(Bool) -> Void) {
        //If statement is responsible for checking if user's friend haven't sent them invitation.
        Firestore.firestore().collection(FirestorePaths.getRequests(uid: Auth.auth().currentUser?.uid ?? "")).getDocuments { snapshot, error in
            if error != nil {
                self.errorMessage = "Error while retrieving the list of requests"
                self.showMessage = true
                completion(false)
            } else {
                if snapshot!.documents.first(where: {$0.documentID == self.uid}) != nil {
                    self.responseType = .requestFromFriend
                    self.showMessage = true
                    completion(false)
                }
                completion(true)
            }
        }
    }

    func checkAgainstDuplicateRequests(completion: @escaping(Bool) -> Void) {
        //If statement is responsible for checking if user haven't sent invitation to friend.
        Firestore.firestore().collection(FirestorePaths.getRequests(uid: self.uid)).getDocuments { snapshot, error in
            if error != nil {
                self.errorMessage = "Error while retrieving the list of requests"
                self.showMessage = true
                completion(false)
            } else {
                if snapshot!.documents.first(where: {$0.documentID == Auth.auth().currentUser?.uid}) != nil {
                    self.responseType = .alreadyInvited
                    self.showMessage = true
                    completion(false)
                }
                completion(true)
            }
        }
    }

    func checkIfNotFriends(completion: @escaping(Bool) -> Void) {
        //If statement is responsible for checking if invited friend is user's friend already.
        Firestore.firestore().collection(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? "")).getDocuments { snapshot, error in
            if error != nil {
                self.errorMessage = "Error while retrieving the list of requests"
                self.showMessage = true
                completion(false)
            } else {
                if snapshot!.documents.first(where: {$0.documentID == self.uid}) != nil {
                    self.responseType = .friendsAlready
                    self.showMessage = true
                    completion(false)
                }
                completion(true)
            }
        }
    }
}
