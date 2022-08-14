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
    
    public var getImage: UIImage {
        return UIImage(data: image ?? Data()) ?? UIImage()
    }
}

extension Photo : Identifiable {

}
