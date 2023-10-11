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
    var date: Date
    var photo: UIImage
    var coordinateLocation: CLLocationCoordinate2D
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
        self.date = Date()
        self.photo = UIImage()
        self.coordinateLocation = CLLocationCoordinate2D()
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

    init(photo: UIImage) {
        self.date = Date()
        self.photo = photo
        self.coordinateLocation = CLLocationCoordinate2D()
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

    init(photo: UIImage, coordinateLocation: CLLocationCoordinate2D) {
        self.date = Date()
        self.photo = photo
        self.coordinateLocation = coordinateLocation
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

    init(
        date: Date,
         photo: UIImage,
         coordinateLocation: CLLocationCoordinate2D,
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
        self.date = date
        self.photo = photo
        self.coordinateLocation = coordinateLocation
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
    var uid: String
    var name: String
    var place: String
    var date: Date
    var operationDate: Date
    var numberOfPhotos: Int
    var photos: [SinglePhoto]

    init() {
        self.uid = ""
        self.name = ""
        self.place = ""
        self.date = Date.now
        self.operationDate = Date.now
        self.numberOfPhotos = 0
        self.photos = []
    }

    init(numberOfPhotos: Int,
         photos: [SinglePhoto],
         photosLocations: [CLLocationCoordinate2D]) {
        self.uid = ""
        self.name = ""
        self.place = ""
        self.date = Date.now
        self.operationDate = Date.now
        self.numberOfPhotos = numberOfPhotos
        self.photos = photos
    }

    init(uid: String,
         name: String,
         place: String,
         date: Date,
         numberOfPhotos: Int) {
        self.uid = uid
        self.name = name
        self.place = place
        self.date = date
        self.operationDate = Date.now
        self.numberOfPhotos = numberOfPhotos
        self.photos = []
    }

    init(uid: String,
         name: String,
         place: String,
         date: Date,
         operationDate: Date,
         numberOfPhotos: Int) {
        self.uid = uid
        self.name = name
        self.place = place
        self.date = date
        self.operationDate = operationDate
        self.numberOfPhotos = numberOfPhotos
        self.photos = []
    }

    init(uid: String,
         name: String,
         place: String,
         date: Date,
         numberOfPhotos: Int,
         photos: [SinglePhoto],
         photosLocations: [CLLocationCoordinate2D]) {
        self.uid = uid
        self.name = name
        self.place = place
        self.date = date
        self.operationDate = Date.now
        self.numberOfPhotos = numberOfPhotos
        self.photos = photos
    }

    init(uid: String,
         name: String,
         place: String,
         date: Date,
         operationDate: Date,
         numberOfPhotos: Int,
         photos: [SinglePhoto],
         photosLocations: [CLLocationCoordinate2D]) {
        self.uid = uid
        self.name = name
        self.place = place
        self.date = date
        self.operationDate = operationDate
        self.operationDate = Date.now
        self.numberOfPhotos = numberOfPhotos
        self.photos = photos
    }

}
