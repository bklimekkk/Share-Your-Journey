//
//  CurrentImage+CoreDataProperties.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 13/08/2022.
//
//

import Foundation
import CoreData
import UIKit

extension CurrentImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentImage> {
        return NSFetchRequest<CurrentImage>(entityName: "CurrentImage")
    }

    @NSManaged public var image: Data?
    @NSManaged public var id: Int16
    @NSManaged public var location: String?
    @NSManaged public var subLocation: String?
    
    public var getImage: UIImage {
        return UIImage(data: self.image ?? Data()) ?? UIImage()
    }
    
    public var getId: Int {
        return Int(self.id)
    }

    public var getLocation: String {
        return self.location ?? ""
    }

    public var getSubLocation: String {
        return self.subLocation ?? ""
    }
}

extension CurrentImage : Identifiable {

}
