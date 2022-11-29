//
//  JourneyPartsComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import MapKit
import UIKit

//In order for locations to be sorted and shown in the right sequence afterwards, objects representing locations need to contain id.
struct PhotoLocation: Identifiable {
    let id: Int
    let location: CLLocationCoordinate2D
}

//Struct represents a single photo.
struct SinglePhoto: Hashable {
    var number: Int
    var photo: UIImage
    var location: String
    var subLocation: String
    var administrativeArea: String
    var country: String
    var isoCountryCode: String
    var name: String
    var postalCode: String
    var ocean: String
    var inlandWater: String
    var areasOfInterest: [String]

    init() {
        self.number = 0
        self.photo = UIImage()
        self.location = ""
        self.subLocation = ""
        self.administrativeArea = ""
        self.country = ""
        self.isoCountryCode = ""
        self.name = ""
        self.postalCode = ""
        self.ocean = ""
        self.inlandWater = ""
        self.areasOfInterest = []
    }

    init(number: Int, photo: UIImage) {
        self.number = number
        self.photo = photo
        self.location = ""
        self.subLocation = ""
        self.administrativeArea = ""
        self.country = ""
        self.isoCountryCode = ""
        self.name = ""
        self.postalCode = ""
        self.ocean = ""
        self.inlandWater = ""
        self.areasOfInterest = []
    }

    init(number: Int,
         photo: UIImage,
         location: String,
         subLocation: String,
         administrativeArea: String,
         country: String,
         isoCountryCode: String,
         name: String,
         postalCode: String,
         ocean: String,
         inlandWater: String,
         areasOfInterest: [String]) {
        self.number = number
        self.photo = photo
        self.location = location
        self.subLocation = subLocation
        self.administrativeArea = administrativeArea
        self.country = country
        self.isoCountryCode = isoCountryCode
        self.name = name
        self.postalCode = postalCode
        self.ocean = ocean
        self.inlandWater = inlandWater
        self.areasOfInterest = areasOfInterest
    }
}

//Struct represents a single journey.
struct SingleJourney: Hashable {
    var email: String
    var name: String
    var place: String
    var date: Date
    var numberOfPhotos: Int
    var photos: [SinglePhoto]
    var photosLocations: [CLLocationCoordinate2D]
    var networkProblem: Bool = false
}
