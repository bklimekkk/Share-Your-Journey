//
//  ResetPasswordView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/04/2022.
//

import SwiftUI

//Struct contains code responsible for generating a button allowing users to reset their password with their e-mail address, if needed. 
struct ResetPasswordView: View {
    
    //This variable is set to e-mail address given by user.
    @Binding var resetEmail: String
    
    //Variable responsible for dismissing reset sheet.
    @Environment(\.presentationMode) var presentationMode
    
    //Variable containing data input by user. 
    @State private var email = ""
    var body: some View {
        VStack (spacing: 20) {
            Text("Enter your email address to reset password")
                .font(.system(size: 30))
            TextField("Your e-mail address", text: $email)
                .font(.system(size: 30))
                .padding(.horizontal, 10)
            Spacer()
            Button{
                
                //Sending a password-reset message to a given email address. 
                FirebaseSetup.firebaseInstance.auth.sendPasswordReset(withEmail: email) { error in
                    if error != nil {
                        print("There was an error while sending reset password email")
                    }
                }
                resetEmail = email
                presentationMode.wrappedValue.dismiss()
            } label: {
                ButtonView(buttonTitle: "Reset password")
            }
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 10)
        }
        .padding()
    }
}
