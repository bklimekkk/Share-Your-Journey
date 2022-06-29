//
//  RunningJourneyModeView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI

//Struct contains code that generates buttons that are supposed to be used by user while the journey is running.
struct RunningJourneyModeView: View {
    
    //Variables are described in StartView struct.
    @Binding var paused: Bool
    @Binding var pickAPhoto: Bool
    @Binding var takeAPhoto: Bool
    var currentLocationManager: CurrentLocationManager
    
    var body: some View {
        HStack {
            Button{
                pickAPhoto = true
                takeAPhoto = true
            } label: {
                Image(systemName: "plus.app.fill")
                    .font(.system(size: 41))
                    .foregroundColor(Color.accentColor)
            }
            
            Button{
                pickAPhoto = false
                takeAPhoto = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 41))
                    .padding([.trailing], 10)
                    .foregroundColor(Color.accentColor)
            }
            
            Button {
                pauseJourney()
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
        currentLocationManager.recenterLocation()
        paused = true
    }
}
