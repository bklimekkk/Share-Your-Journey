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
    let number: Int
    let photo: UIImage
}

//Struct represents a single journey.
struct SingleJourney: Hashable {
    var email: String
    var name: String
    var date: Date
    var numberOfPhotos: Int
    var photos: [SinglePhoto]
    var photosLocations: [CLLocationCoordinate2D]
    var networkProblem: Bool = false
}
