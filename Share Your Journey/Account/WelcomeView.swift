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
                Text(UIStrings.firstWelcomeText)
                Text(UIStrings.secondWelcomeText)
                Text(UIStrings.thirdWelcomeText)
                Text(UIStrings.fourthWelcomeText)
                Text(UIStrings.fifthWelcomeText)
                Text(UIStrings.sixthWelcomeText)
                Text(UIStrings.seventhWelcomeText)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(UIStrings.startUsingTheApp) {
                        self.showInstructions = false
                        self.dismiss()
                    }
                }
            }
            .navigationTitle(UIStrings.welcome)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
