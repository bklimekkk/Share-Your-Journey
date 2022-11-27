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
    @NSManaged public var administrativeArea: String?
    @NSManaged public var country: String?
    @NSManaged public var isoCountryCode: String?
    @NSManaged public var name: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var ocean: String?
    @NSManaged public var inlandWater: String?
    @NSManaged public var areasOfInterest: String?
    
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

    public var getAdministrativeArea: String {
        return self.administrativeArea ?? ""
    }

    public var getCountry: String {
        return self.country ?? ""
    }

    public var getIsoCountryCode: String {
        return self.isoCountryCode ?? ""
    }

    public var getName: String {
        return self.name ?? ""
    }

    public var getPostalCode: String {
        return self.postalCode ?? ""
    }

    public var getOcean: String {
        return self.ocean ?? ""
    }

    public var getInlandWater: String {
        return self.inlandWater ?? ""
    }

    public var getAreasOfInterst: String {
        return self.areasOfInterest ?? ""
    }
}

extension CurrentImage : Identifiable {

}
