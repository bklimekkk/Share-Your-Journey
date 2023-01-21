//
//  SpotDetailsManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 26/11/2022.
//

import Foundation
import MapKit

class SpotDetailsManager: ObservableObject {
    /**
     Function is responsible for getting a placemark from the location.
     */
    func calculatePlace(locationCoordinate: CLLocationCoordinate2D, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error == nil {
                let locationName = placemarks?[0]
                completion(locationName)
            } else {
                completion(nil)
            }
        }
    }
}
