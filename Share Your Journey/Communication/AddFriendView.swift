//
//  AddFriendView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 14/02/2022.
//

import SwiftUI

//Struct is responsible for presenting user with functionality neccessary for inviting a new friend. 
struct AddFriendView: View {
    
    //Enum contains all cases in which users can end up while inviting new friend.
    enum InvitationError {
        case valid
        case yourEmail
        case requestFromFriend
        case emptyField
        case alreadyInvited
        case friendsAlready
        case noAccount
    }
    
    //Variable described in ChatView struct.
    @Binding var sheetIsPresented: Bool
    //Friend's email address.
    @State private var email = UIStrings.emptyString
    //Variable's value justifies if application should present users with any message.
    @State private var showMessage: Bool = false
    //Variable is set to one of enum values from InvitationError.
    @State private var responseType = InvitationError.valid
    
    var body: some View {
        VStack {
            Text(UIStrings.addAFriend)
            TextField(UIStrings.enterFriendsEmail, text: self.$email)
                .font(.system(size: 20))
            Spacer()
            Button{
                //Given email address isn't key sensitive.
                let lowerCasedEmail = self.email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                
                //Each possibility of error connected with inviting friend is checked and prevented with use of if statements below. Statement's aren't contained in separate functions, because each of them contains return key word, which is supposed to stop action performed by button.
                
                //If Statement is responsible for checking if users haven't omit entering data.
                if lowerCasedEmail == UIStrings.emptyString {
                    self.responseType = .emptyField
                    self.showMessage = true
                    return
                }
                
                //If statement is responsible for checking if users haven't entered their own email while inviting a friend.
                if lowerCasedEmail == FirebaseSetup.firebaseInstance.auth.currentUser?.email {
                    self.responseType = .yourEmail
                    self.showMessage = true
                    return
                }
                
                //If statement is responsible for checking if user's friend haven't sent them invitation.
                FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getRequests(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)).getDocuments { snapshot, error in
                    if error != nil {
                        print("Error while retrieving the list of requests")
                    } else {
                        for i in snapshot!.documents {
                            if i.documentID == lowerCasedEmail {
                                self.responseType = .requestFromFriend
                                self.showMessage = true
                                return
                            }
                        }
                    }
                }
                
                //If statement is responsible for checking if user haven't sent invitation to friend.
                FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getRequests(email: lowerCasedEmail)).getDocuments { snapshot, error in
                    if error != nil {
                        print("Error while retrieving the list of requests")
                    } else {
                        for i in snapshot!.documents {
                            if i.documentID == FirebaseSetup.firebaseInstance.auth.currentUser?.email {
                                self.responseType = .alreadyInvited
                                self.showMessage = true
                                return
                            }
                        }
                    }
                }
                
                //If statement is responsible for checking if invited friend is user's friend already.
                FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getFriends(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)).getDocuments { snapshot, error in
                    if error != nil {
                        print("Error while retrieving the list of current friends")
                    } else {
                        for i in snapshot!.documents {
                            if i.documentID == lowerCasedEmail {
                                self.responseType = .friendsAlready
                                self.showMessage = true
                                return
                            }
                        }
                    }
                }
                
                //If statement is responsible for checking if email adress given by user exists in the database.
                FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getUsers()).getDocuments { snapshot, error in
                    if error != nil {
                        print("Error while retrieving the list of users")
                    } else {
                        var emailExists = false
                        for i in snapshot!.documents {
                            if i.documentID == lowerCasedEmail {
                                emailExists = true
                                break
                            }
                        }
                        if !emailExists {
                            self.responseType = .noAccount
                            self.showMessage = true
                            return
                        }
                    }
                }
                
                //If error doesn't occur, message will ask users to confirm friend invitation.
                self.showMessage = true
            } label: {
                ButtonView(buttonTitle: UIStrings.sendRequest)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .alert(isPresented: self.$showMessage) {
            
            //Depending on which error occurs, users are presented to relevant message.
            Alert (title: Text(self.responseType == .valid ? UIStrings.inviteFriend : UIStrings.invitationError),
                   message: Text(self.responseType == .emptyField ? UIStrings.mustProvideEmailAddress : self.responseType == .yourEmail ? UIStrings.yourEmailAddress : self.responseType == .requestFromFriend ? UIStrings.alreadySentYouRequest : responseType == .alreadyInvited ? UIStrings.alreadyInvitedThisPerson : responseType ==  .friendsAlready ? UIStrings.alreadyFriends : self.responseType == .noAccount ? UIStrings.accountDoesntExist : self.email),
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
                    self.email = UIStrings.emptyString
                }
            }
            )
        }
    }
  
    /**
     Function responsible for sending the request to user (pulating relevant 'requests' collection with relevant request data.
     */
    func sendRequest() {
        
        FirebaseSetup.firebaseInstance.db.document("\(FirestorePaths.getRequests(email: email.lowercased()))/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)").setData([
            "email": FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString,
            "deletedAccount": false
        ])
        self.showMessage = false
        self.sheetIsPresented = false
    }
}

