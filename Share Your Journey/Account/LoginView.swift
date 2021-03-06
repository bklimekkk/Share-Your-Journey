//
//  LoginView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 07/02/2022.
//
import SwiftUI
import Firebase
import FirebaseStorage
import RevenueCat

class FirebaseSetup: NSObject {
    
    //Objects defined for firebase authentication and database operations.
    let auth: Auth
    let db: Firestore
    let storage: Storage
    static let firebaseInstance = FirebaseSetup()
    
    //Initializing Firebase instance.
    override init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
        super.init()
    }
}

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
    //Email that users are supposed to enter in order for the application to send reset email.
    @Published var resetEmail = ""
}

class ErrorManager: ObservableObject {
    //This variable is set to true if an error message should be shown.
    @Published var showErrorMessage = false
    
    //This variable is set to relevant error message when needed.
    @Published var errorBody = ""
}

//Struct responsible for presenting login and register screens of the application.
struct LoginView: View {
    let defaults = UserDefaults.standard
    //Variable checks if user uses the application for the first time. If yes, it will show the initial instructions.
    @AppStorage("showInstructions") var showInstructions: Bool = true
    
    //Variables represent user's email, password and name, which are used for registration and logging in processes.
    @State private var email = ""
    @State private var password = ""
    @State private var repeatedPassword = ""
    
    //Variable controls if user is logged in or logged out.
    @Binding var loggedOut: Bool
    
    @StateObject private var accountAccessManager = AccountAccessManager()
    @StateObject private var errorManager = ErrorManager()
    
    @Environment(\.colorScheme) var colorScheme
    
    var forgotPasswordButtonColor: Color {
        colorScheme == .light ? .accentColor : .white
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    //PickerView struct enables users to choos between two "sub" screens.
                    PickerView(choice: $accountAccessManager.register, firstChoice: "Login", secondChoice: "Create account")
                    
                    EmailTextField(label: "E-mail address", email: $email)
                    SecureField("Passowrd", text: $password)
                        .padding(.vertical, 10)
                        .font(.system(size: 20))
                    
                    //If users register themselves, they are supposed to repeat entered password.
                    if accountAccessManager.register {
                        SecureField("Repeat password", text: $repeatedPassword)
                            .padding(.vertical, 10)
                            .font(.system(size: 20))
                    }
                    
                    Button {
                        
                        //Button is used for either logging in or registration.
                        performButtonAction()
                    } label: {
                        
                        //Depending on screen current mode, button will show different message.
                        ButtonView(buttonTitle: accountAccessManager.register ? "Create Account" : "Login")
                    }
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    //Reset password option shows up only when screen presents logging in functionality.
                    if !accountAccessManager.register {
                        Button{
                            accountAccessManager.resetPassword = true
                        } label: {
                            Text("Forgot my password")
                                .foregroundColor(forgotPasswordButtonColor)
                        }
                        .padding(.vertical, 5)
                    }
                    
                }
                .onAppear {
                    email = defaults.string(forKey: "email") ?? ""
                    password = defaults.string(forKey: "password") ?? ""
                }
                .padding()
                .fullScreenCover(isPresented: $accountAccessManager.showVerificationMessage) {
                    accountAccessManager.register = false
                } content: {
                    VerificationInformation(email: email)
                }
                .sheet(isPresented: $accountAccessManager.resetPassword) {
                    if accountAccessManager.resetEmail != "" {
                        accountAccessManager.passwordResetAlert = true
                    }
                } content: {
                    //In this screen, users are only asked to enter their e-mail address.
                    ResetPasswordView(resetEmail: $accountAccessManager.resetEmail, email: email)
                }
            }
            .sheet(isPresented: $showInstructions, content: {
                WelcomeView(showInstructions: $showInstructions)
            })
            .navigationTitle(accountAccessManager.register ? "Create Account" : "Login")
            
            //Title's property is set in a way that it takes possibly smallest space.
            .navigationBarTitleDisplayMode(.inline)
            
            //Alert is presented if any error occurs.
            .alert("Unsuccessfull \(accountAccessManager.register ? "registration" : "login")", isPresented: $errorManager.showErrorMessage) {
                Button("OK", role: .cancel) {
                    errorManager.showErrorMessage = false
                    clearPasswordField()
                }
            } message: {
                Text(errorManager.errorBody)
            }
            
            //Alert is shown to inform users that their password reset email was sent.
            .alert("Password reset e-mail", isPresented: $accountAccessManager.passwordResetAlert, actions: {
                Button("Ok", role: .cancel) {
                    accountAccessManager.resetEmail = ""
                    accountAccessManager.passwordResetAlert = false
                }
            }, message: {
                Text("Reset password e-mail was sent to \(accountAccessManager.resetEmail)")
            })
            
            .alert("Verification error", isPresented: $accountAccessManager.verificationNeeded) {
                Button("Ok"){
                    accountAccessManager.verificationNeeded = false
                }
                Button("Verify again", role: .cancel){
                    sendVerificationEmail()
                }
            } message: {
                Text("Account hasn't been verified yet")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /**
     Function is responsible for sending users a verification e-mail after they complete a registration.
     */
    func sendVerificationEmail() {
        //If users haven't receied verification email, they can click button to re-send it.
        FirebaseSetup.firebaseInstance.auth.currentUser?.sendEmailVerification { error in
            if error != nil {
                print("There was an error while sending verification")
            }
        }
        accountAccessManager.verificationNeeded = false
    }
    
    /**
     After users are presented with error during registraiton, all input fields are cleared.
     */
    func clearPasswordField() {
        if !accountAccessManager.register {
            password = ""
            errorManager.errorBody = ""
        }
    }
    
    /**
     Function performs either login or registration, depending on what mode user is currently at.
     */
    func performButtonAction() {
        if accountAccessManager.register {
            performRegistration()
        } else {
            performLogin()
        }
    }
    
    
    /**
     Function is responsible for authenticating the user.
     */
    func performLogin() {
        //Using firebase as a way to authenticate users by email and passord.
        FirebaseSetup.firebaseInstance.auth.signIn(withEmail: email, password: password) { result, error in
            if(error != nil) {
                errorManager.showErrorMessage = true
                errorManager.errorBody = error?.localizedDescription ?? ""
                return
            }
            
            //Program checks if users verified themselves already.
            let verifiedEmail = result?.user.isEmailVerified ?? false
            if !verifiedEmail {
                accountAccessManager.verificationNeeded = true
                return
            }
            
            //As this variable is set to false, logging in screen disappears and users can access the application.
            loggedOut = false
            
            //As user logs in, default email address and password are set to data they provided.
            defaults.set(FirebaseSetup.firebaseInstance.auth.currentUser?.email, forKey: "email")
            defaults.set(password, forKey: "password")
            Purchases.shared.logIn(result!.user.uid) { (customerInfo, created, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    /**
     Function is responsible for creating new user account, basing on user's details.
     */
    func performRegistration() {
        if password != repeatedPassword {
            
            //If users won't repeat password properly, registration won't go successfully.
            errorManager.showErrorMessage = true
            errorManager.errorBody = "Password fields don't match"
            return
        }
            
            //Firebase is used for creating a new account.
        FirebaseSetup.firebaseInstance.auth.createUser(withEmail: email, password: password) { result, error in
                if error != nil {
                    errorManager.showErrorMessage = true
                    errorManager.errorBody = error?.localizedDescription ?? ""
                    return
                }
                
                //User is added to the firestore database.
            addUser(email: email)
                FirebaseSetup.firebaseInstance.auth.currentUser?.sendEmailVerification { error in
                    if error != nil {
                        print("There was an error while sending verification")
                    }
                }
            accountAccessManager.showVerificationMessage = true
            }
    }
}

/**
 Function is responsible for adding new user to the Firebase server.
 */
func addUser(email: String) {
    //Firebase is used to add user's data to the database.
    
    let instanceReference = FirebaseSetup.firebaseInstance.db
    
    //Each of three collections in Firebase server needs to be populated with new user's date.
    instanceReference.document("users/\(email)").setData([
        "email": email,
        "deletedAccount": false
    ])
    
    instanceReference.document("users/\(email)/friends/\(email)").setData([
        "email": email,
        "deletedAccount": false
    ])
    
    instanceReference.document("users/\(email)/requests/\(email)").setData([
        "email": email,
        "deletedAccount": false
    ])
    
    instanceReference.collection("users/\(email)/friends").getDocuments { querySnapshot, error in
        if let error = error {
            print(error.localizedDescription)
        } else {
            for i in querySnapshot!.documents {
                instanceReference.collection("users/\(i.documentID)/friends").getDocuments { querySnapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        for j in querySnapshot!.documents {
                            if j.documentID == email {
                                instanceReference.collection("users/\(i.documentID)/friends").document(email).updateData(["deletedAccount" : false])
                            }
                        }
                    }
                }
            }
        }
    }
}
