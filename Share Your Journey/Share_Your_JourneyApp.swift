//
//  Share_Your_JourneyApp.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 07/02/2022.
//

import SwiftUI

@main
struct Share_Your_JourneyApp: App {
    var body: some Scene {
        WindowGroup {
            let context = JourneyDataManager.shared.journeyContainer.viewContext
            TabsView().environment(\.managedObjectContext, context)
        }
    }
}
