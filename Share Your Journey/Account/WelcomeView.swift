//
//  InstructionsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 27/06/2022.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showInstructions: Bool
    var body: some View {
        
        NavigationView {
            Form {
                Text("1. Create your account / Log in to existing one.")
                Text("2. Start the journey, travel wherever you want and take pictures.")
                Text("3. Finish and save the journey")
                Text("4. Invite friends using their e-mails.")
                Text("5. Send any previously saved journey to your friend.")
                Text("6. See where your firends went by viewing pictures they took on the map.")
                Text("7. Enjoy!")
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Start using the app") {
                        self.showInstructions = false
                        self.dismiss()
                    }
                }
            }
            .navigationTitle("Welcome to Share Your Journey app")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
