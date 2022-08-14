//
//  JourneyDataManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/03/2022.
//

import Foundation
import CoreData
class JourneyDataManager: ObservableObject {
    let journeyContainer = NSPersistentContainer(name: "Journey")
    init() {
        journeyContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Journey data isn't accessible: \(error)")
            }
        }
        self.journeyContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
