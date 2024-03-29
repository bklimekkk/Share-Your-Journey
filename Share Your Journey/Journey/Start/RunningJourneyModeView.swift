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
    @Binding var loadCamera: Bool
    @ObservedObject var currentLocationManager: CurrentLocationManager
    
    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .blue
    }
    var body: some View {
        HStack {
            Button {
                self.pickAPhoto = true
                self.takeAPhoto = true
            } label: {
                MapButton(imageName: Icons.plus)
                    .foregroundColor(buttonColor)
            }
            
            Button {
                self.loadCamera = true
                self.pickAPhoto = false
                self.takeAPhoto = true
            } label: {
                MapButton(imageName: Icons.cameraFill, load: self.loadCamera)
                    .foregroundColor(buttonColor)
                    .padding(.trailing, 10)
            }
            
            Button {
                self.pauseJourney()
            } label: {
                SymbolButtonView(buttonImage: Icons.pauseFill)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
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
