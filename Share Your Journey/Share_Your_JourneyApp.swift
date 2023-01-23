//
//  Share_Your_JourneyApp.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 07/02/2022.
//

import SwiftUI
import RevenueCat
import Firebase

@main
struct Share_Your_JourneyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var journeyDataManager = JourneyDataManager()
    var body: some Scene {
        WindowGroup {
            TabsView()
                .environment(\.managedObjectContext, journeyDataManager.journeyContainer.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Babcia na zawsze")
        self.setupRevenueCat()
        FirebaseApp.configure()
        return true
    }

    func setupRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Links.revenueCatAPIKey)
    }
}
