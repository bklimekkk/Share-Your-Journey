//
//  CurrentLocation+CoreDataProperties.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 13/08/2022.
//
//

import Foundation
import CoreData


extension CurrentLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentLocation> {
        return NSFetchRequest<CurrentLocation>(entityName: "CurrentLocation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension CurrentLocation : Identifiable {

}
