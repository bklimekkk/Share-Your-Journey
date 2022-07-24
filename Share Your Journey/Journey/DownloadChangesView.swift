//
//  DownloadChangesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 15/04/2022.
//

import SwiftUI

struct DownloadChangesView: View {
    
    //Variables were described in SeeJourneyView struct.
    @Binding var presentSheet: Bool
    @Binding var download: Bool
    @Binding var newName: String
    
    //Variable's value justifies if alert with error needs to be presented to the user.
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Change name")
                .font(.system(size:30))
            
            Spacer()
            TextField("Enter new name", text: $newName)
                .font(.system(size: 30))
            Spacer()
            Button{
                
                //Program require user to enter any name to re-name the journey. 
                if newName != "" {
                    download = true
                    presentSheet = false
                } else {
                    showAlert = true
                }
            } label: {
                ButtonView(buttonTitle: "Download")
            }
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Empty field"), message: Text("You need to provide a name"), dismissButton: .cancel(Text("Ok")) {
                showAlert = false
            })
        }
        .padding()
    }
}
