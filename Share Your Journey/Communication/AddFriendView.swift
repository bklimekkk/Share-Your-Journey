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
    @State private var email = ""
    
    //Variable's value justifies if application should present users with any message.
    @State private var showMessage: Bool = false
    
    //Variable is set to one of enum values from InvitationError.
    @State private var responseType = InvitationError.valid
    var body: some View {
        VStack {
            Text("Add friend")
                .font(.system(size:30))
            
            Spacer()
            TextField("Enter e-mail", text: $email)
                .font(.system(size: 50))
            Spacer()
            Button{
                //Given email address isn't key sensitive.
                let lowerCasedEmail = email.lowercased()
                
                //Each possibility of error connected with inviting friend is checked and prevented with use of if statements below. Statement's aren't contained in separate functions, because each of them contains return key word, which is supposed to stop action performed by button.
                
                //If Statement is responsible for checking if users haven't omit entering data.
                if lowerCasedEmail == "" {
                    responseType = .emptyField
                    showMessage = true
                    return
                }
                
                //If statement is responsible for checking if users haven't entered their own email while inviting a friend.
                if lowerCasedEmail == FirebaseSetup.firebaseInstance.auth.currentUser?.email {
                    responseType = .yourEmail
                    showMessage = true
                    return
                }
                
                //If statement is responsible for checking if user's friend haven't sent them invitation.
                FirebaseSetup.firebaseInstance.db.collection("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/requests").getDocuments { snapshot, error in
                    if error != nil {
                        print("Error while retrieving the list of requests")
                    } else {
                        for i in snapshot!.documents {
                            if i.documentID == lowerCasedEmail {
                                responseType = .requestFromFriend
                                showMessage = true
                                return
                            }
                        }
                    }
                }
                
                //If statement is responsible for checking if user haven't sent invitation to friend.
                FirebaseSetup.firebaseInstance.db.collection("users/\(lowerCasedEmail)/requests").getDocuments { snapshot, error in
                    if error != nil {
                        print("Error while retrieving the list of requests")
                    } else {
                        for i in snapshot!.documents {
                            if i.documentID == FirebaseSetup.firebaseInstance.auth.currentUser?.email {
                                responseType = .alreadyInvited
                                showMessage = true
                                return
                            }
                        }
                    }
                }
                
                //If statement is responsible for checking if invited friend is user's friend already.
                FirebaseSetup.firebaseInstance.db.collection("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends").getDocuments { snapshot, error in
                    if error != nil {
                        print("Error while retrieving the list of current friends")
                    } else {
                        for i in snapshot!.documents {
                            if i.documentID == lowerCasedEmail {
                                responseType = .friendsAlready
                                showMessage = true
                                return
                            }
                        }
                    }
                }
                
                //If statement is responsible for checking if email adress given by user exists in the database.
                FirebaseSetup.firebaseInstance.db.collection("users").getDocuments { snapshot, error in
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
                            responseType = .noAccount
                            showMessage = true
                            return
                        }
                    }
                }
                
                //If error doesn't occur, message will ask users to confirm friend invitation.
                showMessage = true
            } label: {
                ButtonView(buttonTitle: "Send request")
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .alert(isPresented: $showMessage) {
            
            //Depending on which error occurs, users are presented to relevant message.
            Alert (title: Text(responseType == .valid ? "Invite friend" : "Invitation error"),
                   message: Text(responseType == .emptyField ? "You must provide email address" : responseType == .yourEmail ? "This is your email address" : responseType == .requestFromFriend ? "This friend already sent you a friend request" : responseType == .alreadyInvited ? "You already invited this person" : responseType ==  .friendsAlready ? "You are already friends!" : responseType == .noAccount ? "Account doesn't exist" : email),
                   primaryButton: .cancel(Text(responseType == .valid ? "Invite" : "Try again")) {
                if responseType == .valid {
                    sendRequest()
                } else {
                    showMessage = false
                    responseType = .valid
                    email = ""
                }
            },
                   secondaryButton: .destructive(Text(responseType == .valid ? "Cancel" : "Quit")) {
                if responseType == .valid {
                    showMessage = false
                } else {
                    showMessage = false
                    sheetIsPresented = false
                    responseType = .valid
                }
            }
            )
        }
    }
  
    /**
     Function responsible for sending the request to user (pulating relevant 'requests' collection with relevant request data.
     */
    func sendRequest() {
        
        FirebaseSetup.firebaseInstance.db.document("users/\(email.lowercased())/requests/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")").setData([
            "email": FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? ""
        ])
        showMessage = false
        sheetIsPresented = false
    }
}

