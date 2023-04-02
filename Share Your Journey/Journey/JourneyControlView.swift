//
//  JourneyControlView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 25/12/2022.
//

import SwiftUI
import MapKit

struct JourneyControlView: View {
    var numberOfPhotos: Int
    var currentLocationManager: CurrentLocationManager
    @Binding var currentPhoto: SinglePhoto
    @Binding var mapType: MKMapType
    @State var photos: [SinglePhoto]
    var body: some View {
        VStack {
            Spacer()
            HStack {
                PhotosCounterView(currentNumber: (self.photos.firstIndex(of: self.currentPhoto) ?? 0) + 1, overallNumber: self.numberOfPhotos, mapType: self.$mapType)
                Button {
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)
                    // selecting next photo
                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.photos.firstIndex(of: self.currentPhoto) ?? 0) }) ??
                    self.currentLocationManager.mapView.userLocation
                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                } label: {
                    MapButton(imageName: Icons.arrowLeft)
                }
                .disabled(self.photos.firstIndex(of: self.currentPhoto) == 0)
                Button {
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)

                    // selecting previous photo
                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String((self.photos.firstIndex(of: self.currentPhoto) ?? 0) + 2) }) ??
                    self.currentLocationManager.mapView.userLocation
                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                }label: {
                    MapButton(imageName: Icons.arrowRight)
                }
                .disabled(self.photos.firstIndex(of: self.currentPhoto) == self.numberOfPhotos - 1)
            }
        }
    }
}
