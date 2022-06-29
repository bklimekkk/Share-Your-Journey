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
    
    //An environment variable responsible for dismissing the sheet after "OK" button is clicked.
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Image(uiImage: UIImage(systemName: "person.fill.checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)) ?? UIImage())
          
            Text("A verification e-mail has been sent to \(email), verify yourself to be able to log in.")
            }
            .navigationTitle("Verification e-mail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Proceed to app") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
