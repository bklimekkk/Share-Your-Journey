//
//  Photo+CoreDataProperties.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/03/2022.
//
//

import Foundation
import CoreData
import UIKit

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var image: Data?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var journey: Journey?
    @NSManaged public var id: Double
    @NSManaged public var location: String?
    @NSManaged public var subLocation: String?
    
    public var getImage: UIImage {
        return UIImage(data: image ?? Data()) ?? UIImage()
    }

    public var getLocation: String {
        return self.location ?? ""
    }

    public var getSubLocation: String {
        return self.subLocation ?? ""
    }
}

extension Photo : Identifiable {

}
