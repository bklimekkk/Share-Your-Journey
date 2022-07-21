//
//  Share_Your_JourneyApp.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 07/02/2022.
//

import SwiftUI
import RevenueCat

@main
struct Share_Your_JourneyApp: App {
    
    init() {
        setupRevenueCat()
    }
    var body: some Scene {
        WindowGroup {
            let context = JourneyDataManager.shared.journeyContainer.viewContext
            TabsView().environment(\.managedObjectContext, context)
        }
    }
    
    func setupRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_UjmZibTkIjZGigTrJdEeDDVHqqQ")
    }
    
}
