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
    @StateObject private var journeyDataManager = JourneyDataManager()
    init() {
        setupRevenueCat()
    }
    var body: some Scene {
        WindowGroup {
            TabsView()
                .environment(\.managedObjectContext, journeyDataManager.journeyContainer.viewContext)
        }
    }
    
    func setupRevenueCat() {
       // appl_UjmZibTkIjZGigTrJdEeDDVHqqQ
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Links.revenueCatAPIKey)
//        Purchases.configure(withAPIKey: "appl_UjmZibTkIjZGigTrJdEeDDVHqqQ", appUserID: nil, observerMode: false, userDefaults: UserDefaults.standard, useStoreKit2IfAvailable: true)
    }
    
}
