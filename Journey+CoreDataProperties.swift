//
//  Journey+CoreDataProperties.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/03/2022.
//
//

import Foundation
import CoreData


extension Journey {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Journey> {
        return NSFetchRequest<Journey>(entityName: "Journey")
    }

    @NSManaged public var name: String?
    @NSManaged public var place: String?
    @NSManaged public var uid: String?
    @NSManaged public var author: String?
    @NSManaged public var date: Date?
    @NSManaged public var operationDate: Date?
    @NSManaged public var photosNumber: NSNumber?
    @NSManaged public var photos: NSSet?

    public var photosArray: [Photo] {
        return Array(photos as? Set<Photo> ?? []).sorted(by: {
            $0.id < $1.id
        })
    }
}

// MARK: Generated accessors for photos
extension Journey {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

extension Journey : Identifiable {

}
