//
//  StartJourneyModeView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI

//Struct contains code that generates buttons that are supposed to be used by user while the journey hasn't been started yet.
struct StartJourneyModeView: View {
    @Binding var startedJourney: Bool
    var currentLocationManager: CurrentLocationManager
    var body: some View {
        Button {
            withAnimation {
                self.startJourney()
            }
        } label: {
            ButtonView(buttonTitle: "Start journey")
        }
        .background(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /**
     Function responsible for starting the journey activity.
     */
    func startJourney() {
        self.currentLocationManager.recenterLocation()
        withAnimation {
            self.startedJourney = true
        }
    }
}
