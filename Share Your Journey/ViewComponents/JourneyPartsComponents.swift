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
    let photo: UIImage
    
//    enum CodingKeys: CodingKey {
//        case number, photo
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(number, forKey : .number)
//        try container.encode(photo, forKey: .photo)
//    }
//
//    required init(from decoder: Decoder) throws {
//
//    }
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
