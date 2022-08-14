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

    @NSManaged public var image: UIImage?
    @NSManaged public var id: Int16
    
    public var getImage: UIImage {
        return image ?? UIImage()
    }
    
    public var getId: Int {
        return Int(id)
    }
}

extension CurrentImage : Identifiable {

}
