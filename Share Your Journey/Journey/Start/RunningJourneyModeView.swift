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
        colorScheme == .dark || currentLocationManager.mapView.mapType == .hybridFlyover ? .white : .accentColor
    }
    var body: some View {
        HStack {
            Button{
                pickAPhoto = true
                takeAPhoto = true
            } label: {
                Image(systemName: "plus.app.fill")
                    .font(.system(size: 38))
                    .foregroundColor(buttonColor)
            }
            
            Button{
                pickAPhoto = false
                takeAPhoto = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.system(size: 38))
                    .padding([.trailing], 10)
                    .foregroundColor(buttonColor)
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
        withAnimation {
            paused = true
        }
    }
}
