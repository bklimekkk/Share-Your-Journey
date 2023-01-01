//
//  VerificationInformation.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 01/04/2022.
//

import SwiftUI

struct VerificationInformation: View {
    
    //A verification message is sent to this e-mail.
    var email: String
    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .accentColor
    }
    //An environment variable responsible for dismissing the sheet after "Ok" button is clicked.
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            Form {
                Image(systemName: Icons.personFillCheckmark)
                    .foregroundColor(self.buttonColor)
          
                Text("\(UIStrings.verificationEmailSent) \(self.email)\(UIStrings.verifyYourself)")
            }
            .navigationTitle(UIStrings.verificationEmail)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(UIStrings.proceedToApp) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
