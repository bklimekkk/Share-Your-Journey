//
//  LoginView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 07/02/2022.
//
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseMessaging
import RevenueCat

class AccountAccessManager: ObservableObject {
    //Variable responsible for checking if first screen is in registration or in login mode.
    @Published var register = false
    //Variable checks if users verified themselves already.
    @Published var verificationNeeded = false
    //Variable triggers sheet with verification that is shown after users registers successfully.
    @Published var showVerificationMessage = false
    //Variable checks if users want to reset their password.
    @Published var resetPassword = false
    //Variable justifies if screen should present users with reset password message.
    @Published var passwordResetAlert = false
    //Email that users are supposed to enter in order for the application to send reset uid.
    @Published var resetEmail = UIStrings.emptyString
}

class ErrorManager: ObservableObject {
    //This variable is set to true if an error message should be shown.
    @Published var showErrorMessage = false
    //This variable is set to relevant error message when needed.
    @Published var errorBody = UIStrings.emptyString
}

//Struct responsible for presenting login and register screens of the application.
struct LoginView: View {
    let defaults = UserDefaults.standard
    //Variable checks if user uses the application for the first time. If yes, it will show the initial instructions.
    @AppStorage("showInstructions") var showInstructions: Bool = true
    //Variables represent user's uid, password and name, which are used for registration and logging in processes.
    @State private var email = UIStrings.emptyString
    @State private var password = UIStrings.emptyString
    @State private var nickname = UIStrings.emptyString
    @State private var repeatedPassword = UIStrings.emptyString
    //Variable controls if user is logged in or logged out.
    @Binding var loggedOut: Bool
    @StateObject private var accountAccessManager = AccountAccessManager()
    @StateObject private var errorManager = ErrorManager()
    @Environment(\.colorScheme) var colorScheme
    var forgotPasswordButtonColor: Color {
        self.colorScheme == .light ? .blue : .white
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    //PickerView struct enables users to choos between two "sub" screens.
                    PickerView(choice: self.$accountAccessManager.register,
                               firstChoice: UIStrings.login,
                               secondChoice: UIStrings.createAccount)
                    EmailTextField(label: UIStrings.emailAddress, email: $email)
                    if self.accountAccessManager.register {
                        TextField(UIStrings.nickname, text: self.$nickname)
                            .padding(.vertical, 10)
                            .font(.system(size: 20))
                    }
                    SecureField(UIStrings.password, text: self.$password)
                        .padding(.vertical, 10)
                        .font(.system(size: 20))
                    //If users register themselves, they are supposed to repeat entered password.
                    if self.accountAccessManager.register {
                        SecureField(UIStrings.repeatPassword, text: self.$repeatedPassword)
                            .padding(.vertical, 10)
                            .font(.system(size: 20))
                    }
                    Button {
                        //Button is used for either logging in or registration.
                        self.performButtonAction()
                    } label: {
                        //Depending on screen current mode, button will show different message.
                        ButtonView(buttonTitle: self.accountAccessManager.register ? UIStrings.createAccount : UIStrings.login)
                    }
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    //Reset password option shows up only when screen presents logging in functionality.
                    if !self.accountAccessManager.register {
                        Button{
                            self.accountAccessManager.resetPassword = true
                        } label: {
                            Text(UIStrings.forgotMyPassword)
                                .foregroundColor(self.forgotPasswordButtonColor)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onAppear {
                    self.email = self.defaults.string(forKey: UIStrings.emailKey) ?? UIStrings.emptyString
                    self.password = self.defaults.string(forKey: UIStrings.passwordKey) ?? UIStrings.emptyString
                }
                .padding()
                .fullScreenCover(isPresented: self.$accountAccessManager.showVerificationMessage) {
                    self.accountAccessManager.register = false
                } content: {
                    VerificationInformation(email: email)
                }
                .sheet(isPresented: self.$accountAccessManager.resetPassword) {
                    if self.accountAccessManager.resetEmail != UIStrings.emptyString {
                        self.accountAccessManager.passwordResetAlert = true
                    }
                } content: {
                    //In this screen, users are only asked to enter their email address.
                    ResetPasswordView(resetEmail: self.$accountAccessManager.resetEmail, email: self.email)
                }
            }
            .sheet(isPresented: self.$showInstructions, content: {
                WelcomeView(showInstructions: self.$showInstructions)
            })
            .navigationTitle(self.accountAccessManager.register ? UIStrings.createAccount : UIStrings.login)
            //Title's property is set in a way that it takes possibly smallest space.
            .navigationBarTitleDisplayMode(.inline)
            //Alert is presented if any error occurs.
            .alert("Unsuccessfull \(self.accountAccessManager.register ? "registration" : "login")", isPresented: self.$errorManager.showErrorMessage) {
                Button(UIStrings.ok, role: .cancel) {
                    self.errorManager.showErrorMessage = false
                    self.clearPasswordField()
                }
            } message: {
                Text(self.errorManager.errorBody)
            }
            //Alert is shown to inform users that their password reset uid was sent.
            .alert(UIStrings.passwordResetEmail, isPresented: self.$accountAccessManager.passwordResetAlert, actions: {
                Button(UIStrings.ok, role: .cancel) {
                    self.accountAccessManager.resetEmail = UIStrings.emptyString
                    self.accountAccessManager.passwordResetAlert = false
                }
            }, message: {
                Text("\(UIStrings.resetPasswordEmailSent) \(self.accountAccessManager.resetEmail)")
            })
            .alert(UIStrings.verificationError, isPresented: self.$accountAccessManager.verificationNeeded) {
                Button(UIStrings.ok){
                    self.accountAccessManager.verificationNeeded = false
                }
                Button(UIStrings.verifyAgain, role: .cancel){
                    self.sendVerificationEmail()
                }
            } message: {
                Text(UIStrings.accountNotYetVerified)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /**
     Function is responsible for sending users a verification email after they complete a registration.
     */
    func sendVerificationEmail() {
        //If users haven't receied verification uid, they can click button to re-send it.
        Auth.auth().currentUser?.sendEmailVerification { error in
            if error != nil {
                print(UIStrings.sendingVerificationError)
            }
        }
        self.accountAccessManager.verificationNeeded = false
    }
    
    /**
     After users are presented with error during registraiton, all input fields are cleared.
     */
    func clearPasswordField() {
        if !self.accountAccessManager.register {
            self.password = UIStrings.emptyString
            self.errorManager.errorBody = UIStrings.emptyString
        }
    }
    
    /**
     Function performs either login or registration, depending on what mode user is currently at.
     */
    func performButtonAction() {
        if self.accountAccessManager.register {
            self.performRegistration()
        } else {
            self.performLogin(completion: {
                HapticFeedback.heavyHapticFeedback()
            })
        }
    }
    
    /**
     Function is responsible for authenticating the user.
     */
    func performLogin(completion: @escaping() -> Void) {
        //Using firebase as a way to authenticate users by uid and passord.
        Auth.auth().signIn(withEmail: self.email, password: self.password) { result, error in
            if(error != nil) {
                self.errorManager.showErrorMessage = true
                self.errorManager.errorBody = error?.localizedDescription ?? UIStrings.emptyString
                return
            }
            //Program checks if users verified themselves already.
            let verifiedEmail = result?.user.isEmailVerified ?? false
            if !verifiedEmail {
                self.accountAccessManager.verificationNeeded = true
                return
            }
            //As this variable is set to false, logging in screen disappears and users can access the application.
            self.loggedOut = false
            //As user logs in, default uid address and password are set to data they provided.
            self.defaults.set(Auth.auth().currentUser?.email, forKey: UIStrings.emailKey)
            self.defaults.set(self.password, forKey: UIStrings.passwordKey)
            Purchases.shared.logIn(result!.user.uid) { (customerInfo, created, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            let token = Messaging.messaging().fcmToken
            let usersRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? UIStrings.emptyString)
            usersRef.setData(["fcmToken": token ?? ""], merge: true)
            AccountManager.getNickname(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString) { nickname in
                self.defaults.set(nickname, forKey: "nickname")
            }
            completion()
        }
    }
    
    /**
     Function is responsible for creating new user account, basing on user's details.
     */
    func performRegistration() {
        if self.password != self.repeatedPassword {
            //If users won't repeat password properly, registration won't go successfully.
            self.errorManager.showErrorMessage = true
            self.errorManager.errorBody = UIStrings.passwordFieldsNotMatching
            return
        }

        if !self.nickname.isEmpty {
            AccountManager.checkNicknameUniqueness(nickname: self.nickname) { nicknameAvailable in
                if nicknameAvailable {
                    //Firebase is used for creating a new account.
                    Auth.auth().createUser(withEmail: self.email, password: self.password) { result, error in
                        if error != nil {
                            self.errorManager.showErrorMessage = true
                            self.errorManager.errorBody = error?.localizedDescription ?? UIStrings.emptyString
                            return
                        }
                        //User is added to the firestore database.
                        self.addUser(email: self.email, nickname: self.nickname, uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString)
                        Auth.auth().currentUser?.sendEmailVerification { error in
                            if error != nil {
                                print(UIStrings.sendingVerificationError)
                            }
                        }
                        self.accountAccessManager.showVerificationMessage = true
                    }
                } else {
                    self.errorManager.showErrorMessage = true
                    self.errorManager.errorBody = UIStrings.nicknameIsTaken
                    self.nickname = UIStrings.emptyString
                }
            }
        } else {
            self.errorManager.showErrorMessage = true
            self.errorManager.errorBody = UIStrings.emptyNicknameField
        }
    }

    /**
     Function is responsible for adding new user to the Firebase server.
     */
    func addUser(email: String, nickname: String, uid: String) {
        //Firebase is used to add user's data to the database.
        let instanceReference = Firestore.firestore()
        //Each of three collections in Firebase server needs to be populated with new user's date.
        instanceReference.document("\(FirestorePaths.users)/\(uid)").setData([
            "nickname": nickname,
            "deletedAccount": false
        ])
        instanceReference.document("\(FirestorePaths.getFriends(uid: uid))/\(uid)").setData(["deletedAccount": false])
        instanceReference.collection(FirestorePaths.getFriends(uid: uid)).getDocuments { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    instanceReference.collection(FirestorePaths.getFriends(uid: i.documentID)).getDocuments { querySnapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            for j in querySnapshot!.documents {
                                if j.documentID == uid {
                                    instanceReference.collection(FirestorePaths.getFriends(uid: i.documentID)).document(uid).updateData(["deletedAccount" : false])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
