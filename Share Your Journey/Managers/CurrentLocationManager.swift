//
//  CurrentLocationManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 14/02/2022.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI

class CurrentLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    //These two objects are responsible for both providing map to the main screen of the application (mapView) and updating user's location on the map (currentRegion)
    @Published var mapView = MKMapView()
    @Published var currentRegion = MKCoordinateRegion()
    
    //This object will be used for setting all map properties that will provide fully functional map in the main screen of the application.
    private let manager = CLLocationManager()
    
    var centeredLocation = false
    
    //In this overriden init block, manager object, which was created in this file has its delegate property set to self. Because of this, following lines containing assignments and functions calls, will be able to provide the final map with needed functionality.
    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        //Application needs to keep track of user's location even if application runs in the background or if the phone is locked.
        self.manager.requestWhenInUseAuthorization()
        
        //These two lines (1) show user's location on the map and (2) enable the map show location changes.
        self.manager.startUpdatingLocation()
        self.manager.allowsBackgroundLocationUpdates = true
    }
    
    /**
     Function responsible for updating user's current location. It's called every time when user changes the location.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Calling "last" on locations ensures that last recorded location is used.
        locations.last.map {
            
            //Created earlier object is assigned to coordinates of user. latitudialMeters and longitudalmeters parameters set width and height of the map in the beginning.
            self.currentRegion = MKCoordinateRegion(center: $0.coordinate,
                                                    latitudinalMeters: CLLocationDistance(IntConstants.initialMapVisibleMeters),
                                                    longitudinalMeters: CLLocationDistance(IntConstants.initialMapVisibleMeters))
            
            //When main screen with the map is opened, it is centered on the user's location. It only happens once.
            if !self.centeredLocation {
                self.centerLocation()
                self.centeredLocation = true
            }
        }
    }
    
    /**
     Function is responsible for recentering the map on user's location.
     */
    func recenterLocation() {
        self.mapView.setCenter(self.currentRegion.center, animated: true)
        //this line provides a smooth animation to centering aciton.
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    /**
     Function is responsible for centering the map on user's location.
     */
    func centerLocation() {
        self.mapView.setRegion(self.currentRegion, animated: false)
    }

    /**
     Function is responsible for centering the map's visible region on specific coordinates.
     */
    func centerMapOnPin(location: CLLocationCoordinate2D) {
        self.mapView.setCenter(location, animated: true)
        //this line provides a smooth animation to centering aciton.
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    /**
     This function is responsible for changing the type of map.
     */
    func changeTypeOfMap() {
        if self.mapView.mapType == .standard {
            self.mapView.mapType = .hybridFlyover
        } else {
            self.mapView.mapType = .standard
        }
    }
}
