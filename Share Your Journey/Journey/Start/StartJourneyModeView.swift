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
        let sender = NotificationSender()
        sender.sendPushNotification(to: "e5TFxN0lJ06pl32dYFzKlN:APA91bGKNylhMl1gb0Xk3kcSf1ak77ZDS1FldyOuX-cajph33LRYdy3x0tdrx3q4AtbS6S2zKxsKDm6EZ7-S4-bRUCdCexrbn94SddGcsEM-kFb-cg7lO4wvPwKTHmNlgdaLuNw8gnG5", title: "Notification title", body: "Notification body")

    }
}
