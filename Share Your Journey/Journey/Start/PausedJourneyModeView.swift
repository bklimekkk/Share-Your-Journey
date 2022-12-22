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
            MapButton(imageName: "plus.app.fill")
                .disabled(true)
            MapButton(imageName: "camera.fill")
                .disabled(true)
                .padding(.trailing, 10)
            Button {
                self.resumeJourney()
            } label: {
                SymbolButtonView(buttonImage: "play.fill")
            }
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            Button {
                self.alert = .finish
                
                if self.arrayOfPhotos.count > 0 {
                    self.alertMessage = true
                } else {
                    self.alertBody = "Journey should contain at least one photo"
                    self.alertError = true
                }
            } label: {
                SymbolButtonView(buttonImage: "checkmark")
            }
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            Button {
                self.alert = .quit
                self.alertMessage = true
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
        self.currentLocationManager.recenterLocation()
        self.startedJourney = true
        self.paused = false
    }
}
