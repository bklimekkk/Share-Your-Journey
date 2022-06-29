//
//  PausedJourneyModeView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI

//Struct contains code that generates buttons that are supposed to be used by user while the journey is paused.
struct PausedJourneyModeView: View {
    
    //Variables are described in StartView struct.
    @Binding var arrayOfPhotos: [SinglePhoto]
    @Binding var alertMessage: Bool
    @Binding var alertError: Bool
    @Binding var paused: Bool
    @Binding var startedJourney: Bool
    @Binding var alert: StartView.AlertType
    @Binding var alertBody: String
    var currentLocationManager: CurrentLocationManager
    
    var body: some View {
        HStack {
            Image(systemName: "plus.app.fill")
                .font(.system(size: 41))
                .foregroundColor(.gray)
                .disabled(true)
            
            Image(systemName: "camera.fill")
                .font(.system(size: 41))
                .foregroundColor(.gray)
                .padding([.trailing], 10)
                .disabled(true)
            
            Button {
                resumeJourney()
            } label: {
                SymbolButtonView(buttonImage: "play.fill")
            }
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            Button {
                alert = .finish
                
                if arrayOfPhotos.count > 0 {
                    alertMessage = true
                } else {
                    alertBody = "Journey should contain at least one photo"
                    alertError = true
                }
            } label: {
                SymbolButtonView(buttonImage: "checkmark")
            }
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            Button {
                alert = .quit
                alertMessage = true
            } label: {
                SymbolButtonView(buttonImage: "xmark")
            }
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    /**
     Function responsible for resuming the journey activity.
     */
    func resumeJourney() {
        currentLocationManager.recenterLocation()
        startedJourney = true
        paused = false
    }
}
