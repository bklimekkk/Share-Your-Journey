//
//  MapView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/02/2022.
//

import Foundation
import MapKit
import SwiftUI

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        return normalizedImage;
    }
}

struct MapView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var walking: Bool
    @Binding var showPhoto: Bool
    @Binding var photoIndex: Int
    @Binding var showWeather: Bool
    @Binding var expandWeather: Bool
    @Binding var weatherLatitude: Double
    @Binding var weatherLongitude: Double
    
    var tintColor: UIColor {
        self.colorScheme == .light ? UIColor(red: 0.36, green: 0.09, blue: 0.92, alpha: 1.00) : .white
    }
    //This array is supposed to contain all places that user visited in the StartView screen during the journey.
    var photos: [UIImage]
    var photosLocations: [CLLocationCoordinate2D]
    
    
    //This object is annotated as environmental in order to be called from many views.
    @EnvironmentObject var clManager: CurrentLocationManager
    
    //Coordinator class is used to provide communication between all user's actions and the map. Each MapView() will need to define enfirontment object of type CurrentLocationManager.
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let title = view.annotation?.title, title != "My Location" {
                
                if let validTitle = Int(title!) {
                    self.parent.photoIndex = validTitle - 1
                }
                self.parent.clManager.mapView.setCenter(view.annotation!.coordinate, animated: true)
            }
            
            self.parent.weatherLatitude = view.annotation?.coordinate.latitude ?? 0.0
            self.parent.weatherLongitude = view.annotation?.coordinate.longitude ?? 0.0
            
            withAnimation(.easeInOut(duration: 0.15)) {
                self.parent.showWeather = true
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            withAnimation(.easeInOut(duration: 0.15)) {
                self.parent.expandWeather = false
            }
            withAnimation(.easeInOut(duration: 0.15)) {
                self.parent.showWeather = false
            }
        }
        
        /**
         Function is responsible for specifying the way how annotations should look like on 3D map and what functionality they should present.
         */
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let marker = MKMarkerAnnotationView()
            marker.annotation = annotation
            marker.titleVisibility = .hidden
            if annotation.title != "My Location" {
                marker.markerTintColor = self.parent.tintColor
                marker.glyphText = annotation.title as? String
                marker.canShowCallout = true
                
                let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 40))
                
                let iconSizeConfiguration = UIImage.SymbolConfiguration(pointSize: 25)
                
                leftButton.setImage(UIImage(systemName: "location.north.circle", withConfiguration: iconSizeConfiguration), for: .normal)
                rightButton.setImage(UIImage(systemName: "camera", withConfiguration: iconSizeConfiguration), for: .normal)
                
                leftButton.tintColor = self.parent.tintColor
                rightButton.tintColor = self.parent.tintColor
                
                marker.leftCalloutAccessoryView = leftButton
                marker.rightCalloutAccessoryView = rightButton
            } else {
                marker.markerTintColor = .systemBlue
                marker.glyphImage = UIImage(systemName: "person.fill")
                marker.selectedGlyphImage = UIImage(systemName: "person")
            }
            
            return marker
        }
        
        /**
         Function is responsible for generating a route to a place selected by user.
         */
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if view.rightCalloutAccessoryView == control {
                withAnimation(.easeInOut(duration: 0.15)) {
                    self.parent.showPhoto = true
                }
            } else {
                let overlays = mapView.overlays
                mapView.removeOverlays(overlays)
                let firstPoint = MKPlacemark(coordinate: self.parent.clManager.currentRegion.center)
                let secondPoint = MKPlacemark(coordinate: view.annotation!.coordinate)
                let routeRequest = MKDirections.Request()
                routeRequest.source = MKMapItem(placemark: firstPoint)
                routeRequest.destination = MKMapItem(placemark: secondPoint)
                
                //Depending on the choice, application will present users with different type of directions.
                if self.parent.walking {
                    routeRequest.transportType = .walking
                } else {
                    routeRequest.transportType = .automobile
                }
                
                let directions = MKDirections(request: routeRequest)
                directions.calculate { response, error in
                    if let route = response?.routes.first {
                        mapView.addOverlay(route.polyline)
                        
                        //Specifying how map's visible region should change when application displays a route.
                        mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100), animated: true)
                    } else {
                        return
                    }
                }
            }
        }
        
        
        /**
         Code in this function makes sure that all routes that were created, will appear on the map.
         */
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderedRoutes = MKPolylineRenderer(overlay: overlay)
            renderedRoutes.strokeColor = .systemBlue
            renderedRoutes.fillColor = .systemGreen
            renderedRoutes.lineJoin = .round
            renderedRoutes.lineCap = .round
            renderedRoutes.miterLimit = .infinity
            
            renderedRoutes.lineWidth = 7
            return renderedRoutes
        }
    }
    
    /**
     Function responsible for returning Coorinator object
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /**
     Function returning MKMapView object, which means that this object, before it's returned, needs to have its properties assigned so that map is fully functional.
     */
    func makeUIView(context: Context) -> MKMapView {
        //mapView variable is set to mapView variable of clmanager(CurrentLocationManager object). Thanks to this changes from this object will update this mapView.
        let mapView = self.clManager.mapView
        
        //mapView's delecate should be assigned to context.coordinator for the map to interact with user fully.
        mapView.delegate = context.coordinator
        
        //Setting this Bool variable to true makes sure that application will present users with their location.
        mapView.showsUserLocation = true
        
        //Setting this property of mapView object ensures that the map will update user's location when they change it.
        mapView.userTrackingMode = .follow
        
        //Calling this function over here causes adding all user's locations that were recorded during the journey.
        //        LOCATION FUNCTIONALITY DOESN'T WORK YET
        //        addUserLocations(mapView: mapView)
        self.addPhotos(mapView: mapView)
        
        if self.photosLocations.count > 0 {
            self.clManager.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.photosLocations[0].latitude, longitude: self.photosLocations[0].longitude), latitudinalMeters: 1000, longitudinalMeters: 1000), animated: false)
        }
        return mapView
    }
    
    /**
     Function is responsible for adding photo's annotation to the map.
     */
    func addPhotos(mapView: MKMapView) {
        var index = 0
        while index < self.photosLocations.count {
            let photoPin = MKPointAnnotation()
            photoPin.title = String(index + 1)
            photoPin.coordinate = self.photosLocations[index]
            mapView.addAnnotation(photoPin)
            index+=1
        }
    }
    
    /**
     Function responsible updating contents of the map (for the future development).
     */
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
