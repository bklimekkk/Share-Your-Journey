//
//  ResetPasswordView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/04/2022.
//

import SwiftUI
import Firebase

//Struct contains code responsible for generating a button allowing users to reset their password with their email address, if needed. 
struct ResetPasswordView: View {
    //This variable is set to email address given by user.
    @Binding var resetEmail: String
    //Variable responsible for dismissing reset sheet.
    @Environment(\.dismiss) var dismiss
    //Variable containing data input by user.
    @State var email: String
    @StateObject private var errorManager = ErrorManager()
    
    var body: some View {
        VStack (spacing: 20) {
            Text(UIStrings.enterEmailToReset)
            EmailTextField(label: UIStrings.yourEmail, email: self.$email)
                .padding(.horizontal, 10)
            Spacer()
            Button{
                if self.email.isEmpty {
                    self.errorManager.errorBody = UIStrings.enterEmailToReset
                    self.errorManager.showErrorMessage = true
                    return
                }
                //Sending a password-reset message to a given uid address.
                Auth.auth().sendPasswordReset(withEmail: self.email) { error in
                    if error != nil {
                        print(UIStrings.resetPasswordEmailError)
                    }
                }
                self.resetEmail = self.email
                self.dismiss()
            } label: {
                ButtonView(buttonTitle: UIStrings.resetPassword)
            }
            .alert(UIStrings.emailFieldIsEmpty,
                   isPresented: self.$errorManager.showErrorMessage,
                   actions: {},
                   message: {
                Text(self.errorManager.errorBody)
            })
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .padding(.horizontal, 10)
        }
        .padding()
    }
}
