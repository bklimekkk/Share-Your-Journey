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
    //An environment variable responsible for dismissing the sheet after "OK" button is clicked.
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            Form {
                Image(systemName: "person.fill.checkmark")
                    .foregroundColor(self.buttonColor)
          
                Text("A verification e-mail has been sent to \(self.email), verify yourself to be able to log in. If you don't find the e-mail, make sure you check the spam.")
            }
            .navigationTitle("Verification e-mail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Proceed to app") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
