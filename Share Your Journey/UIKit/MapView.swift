//
//  MapView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/02/2022.
//

import Foundation
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var walking: Bool
    @Binding var showPhoto: Bool
    @Binding var showWeather: Bool
    @Binding var showDirections: Bool
    @Binding var expandWeather: Bool
    @Binding var weatherLatitude: Double
    @Binding var weatherLongitude: Double
    @Binding var routeIsDisplayed: Bool
    @Binding var selectedPhoto: SinglePhoto
    var tintColor: UIColor {
        self.colorScheme == .light ? Colors.darkTintColor : .white
    }
    @State var photos: [SinglePhoto]
    
    //This object is annotated as environmental in order to be called from many views.
    @EnvironmentObject var clManager: CurrentLocationManager
    
    //Coordinator class is used to provide communication between all user's actions and the map. Each MapView()
    //will need to define enfirontment object of type CurrentLocationManager.
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation
            {
                self.parent.selectedPhoto = self.parent.photos.first(where: { $0.coordinateLocation == annotation.coordinate }) ?? SinglePhoto()
                self.parent.clManager.mapView.selectAnnotation(annotation, animated: true)
                self.parent.showDirections = true
            } else {
                self.parent.showDirections = false
            }
            self.parent.weatherLatitude = view.annotation?.coordinate.latitude ?? 0.0
            self.parent.weatherLongitude = view.annotation?.coordinate.longitude ?? 0.0
            withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                self.parent.showWeather = true
            }
            HapticFeedback.heavyHapticFeedback()
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                self.parent.expandWeather = false
            }
            withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                self.parent.showWeather = false
            }
            self.parent.showDirections = false
        }
        
        /**
         Function is responsible for specifying the way how annotations should look like on 3D map and what functionality they should present.
         */
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let marker = MKMarkerAnnotationView()
            marker.annotation = annotation
            marker.titleVisibility = .hidden
            if annotation.title != UIStrings.myLocationString {
                marker.markerTintColor = self.parent.tintColor
                marker.glyphText = annotation.title as? String
                marker.canShowCallout = true
                let leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 40))
                let iconSizeConfiguration = UIImage.SymbolConfiguration(pointSize: 25)
                leftButton.setImage(UIImage(systemName: Icons.locationNorthCircle, withConfiguration: iconSizeConfiguration), for: .normal)
                rightButton.setImage(UIImage(systemName: Icons.camera, withConfiguration: iconSizeConfiguration), for: .normal)
                leftButton.tintColor = self.parent.tintColor
                rightButton.tintColor = self.parent.tintColor
                marker.leftCalloutAccessoryView = leftButton
                marker.rightCalloutAccessoryView = rightButton
            } else {
                marker.markerTintColor = .systemBlue
                marker.glyphImage = UIImage(systemName: Icons.personFill)
                marker.selectedGlyphImage = UIImage(systemName: Icons.person)
            }
            return marker
        }
        
        /**
         Function is responsible for generating a route to a place selected by user.
         */
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if view.rightCalloutAccessoryView == control {
                withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                    self.parent.showPhoto = true
                }
            } else {
                withAnimation {
                    self.parent.routeIsDisplayed = true
                }
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
                        mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                                  edgePadding: UIEdgeInsets(top: 0,
                                                                            left: 100,
                                                                            bottom: 0,
                                                                            right: 100),
                                                  animated: true)
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
            renderedRoutes.lineWidth = CGFloat(IntConstants.routeWidth)
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
        if self.photos.count > 0 {
            self.clManager.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.photos[0].coordinateLocation.latitude,
                                                                                               longitude: self.photos[0].coordinateLocation.longitude),
                                                                latitudinalMeters: CLLocationDistance(IntConstants.initialMapVisibleMeters),
                                                                longitudinalMeters: CLLocationDistance(IntConstants.initialMapVisibleMeters)),
                                             animated: false)
        }
        return mapView
    }
    
    /**
     Function is responsible for adding photo's annotation to the map.
     */
    func addPhotos(mapView: MKMapView) {

        self.photos.forEach { photo in
            guard let index = self.photos.firstIndex(of: photo) else {
                return
            }

            let photoPin = MKPointAnnotation()
            photoPin.title = String(index + 1)
            photoPin.coordinate = self.photos[index].coordinateLocation
            mapView.addAnnotation(photoPin)
        }
    }
    
    /**
     Function responsible updating contents of the map (for the future development).
     */
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}
