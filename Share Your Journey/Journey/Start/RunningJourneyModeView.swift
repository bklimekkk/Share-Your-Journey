//
//  RunningJourneyModeView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI

//Struct contains code that generates buttons that are supposed to be used by user while the journey is running.
struct RunningJourneyModeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    //Variables are described in StartView struct.
    @Binding var paused: Bool
    @Binding var pickAPhoto: Bool
    @Binding var takeAPhoto: Bool
    @ObservedObject var currentLocationManager: CurrentLocationManager
    
    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .accentColor
    }
    var body: some View {
        HStack {
            Button{
                self.pickAPhoto = true
                self.takeAPhoto = true
            } label: {
                MapButton(imageName: "plus")
            }
            
            Button{
                self.pickAPhoto = false
                self.takeAPhoto = true
            } label: {
                MapButton(imageName: "camera.fill")
                    .padding(.trailing, 10)
            }
            
            Button {
                self.pauseJourney()
            } label: {
                SymbolButtonView(buttonImage: "pause.fill")
            }
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    /**
     Function responsible for pausing the journey activity.
     */
    func pauseJourney() {
        self.currentLocationManager.recenterLocation()
        self.paused = true
    }
}
