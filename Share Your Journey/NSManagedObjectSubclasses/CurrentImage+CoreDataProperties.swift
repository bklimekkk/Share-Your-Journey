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
        return self.location ?? UIStrings.emptyString
    }

    public var getSubLocation: String {
        return self.subLocation ?? UIStrings.emptyString
    }

    public var getAdministrativeArea: String {
        return self.administrativeArea ?? UIStrings.emptyString
    }

    public var getCountry: String {
        return self.country ?? UIStrings.emptyString
    }

    public var getIsoCountryCode: String {
        return self.isoCountryCode ?? UIStrings.emptyString
    }

    public var getName: String {
        return self.name ?? UIStrings.emptyString
    }

    public var getPostalCode: String {
        return self.postalCode ?? UIStrings.emptyString
    }

    public var getOcean: String {
        return self.ocean ?? UIStrings.emptyString
    }

    public var getInlandWater: String {
        return self.inlandWater ?? UIStrings.emptyString
    }

    public var getAreasOfInterst: String {
        return self.areasOfInterest ?? UIStrings.emptyString
    }
}

extension CurrentImage : Identifiable {

}
