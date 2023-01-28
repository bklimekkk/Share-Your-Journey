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
            self.startJourney()
        } label: {
            ButtonView(buttonTitle: UIStrings.startJourney)
        }
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /**
     Function responsible for starting the journey activity.
     */
    func startJourney() {
        self.currentLocationManager.recenterLocation()
        self.startedJourney = true
        HapticFeedback.heavyHapticFeedback()
    }
}
