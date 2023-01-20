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
            Text(UIStrings.changeName)
                .font(.system(size:30))
            
            Spacer()
            TextField(UIStrings.enterNewName, text: $newName)
                .font(.system(size: 30))
            Spacer()
            Button{
                
                //Program require user to enter any name to re-name the journey. 
                if self.newName != UIStrings.emptyString {
                    self.download = true
                    self.presentSheet = false
                } else {
                    self.showAlert = true
                }
            } label: {
                ButtonView(buttonTitle: UIStrings.download)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(UIStrings.emptyField),
                  message: Text(UIStrings.youNeedToProvideAName),
                  dismissButton: .cancel(Text(UIStrings.ok)) {
                self.showAlert = false
            })
        }
        .padding()
    }
}
