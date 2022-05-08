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
        VStack (spacing: 20) {
            Image(uiImage: UIImage(systemName: "person.fill.checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 72)) ?? UIImage())
      
        Text("A verification e-mail has been sent to \(email), verify yourself to be able to log in")
                .font(.system(size: 30))
            Button{
                presentationMode.wrappedValue.dismiss()
            } label:{
                ButtonView(buttonTitle: "OK")
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}
