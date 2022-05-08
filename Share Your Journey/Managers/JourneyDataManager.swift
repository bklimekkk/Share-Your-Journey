//
//  JourneyDataManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/03/2022.
//

import Foundation
import CoreData
class JourneyDataManager {
    
    let journeyContainer: NSPersistentContainer
    static let shared = JourneyDataManager()
    
    private init() {
      journeyContainer = NSPersistentContainer(name: "Journey")
        journeyContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Journey data isn't accessible: \(error)")
            }
        }
    }
}
