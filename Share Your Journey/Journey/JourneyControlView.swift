//
//  JourneyControlView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 25/12/2022.
//

import SwiftUI
import MapKit

struct JourneyControlView: View {
    var journey: SingleJourney
    var currentLocationManager: CurrentLocationManager
    @Binding var currentPhotoIndex: Int
    var body: some View {
        VStack {
            Spacer()
            HStack {
                PhotosCounterView(number: self.currentPhotoIndex + 1)
                Button {
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)
                    print(self.currentPhotoIndex)
                    self.currentPhotoIndex -= 1
                    print(self.currentPhotoIndex)
                    self.currentLocationManager.centerMapOnPin(location:
                                                                self.journey.photosLocations[currentPhotoIndex])
                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.currentPhotoIndex + 1)}) ??
                    self.currentLocationManager.mapView.userLocation
                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                }label: {
                    MapButton(imageName: Icons.arrowLeft)
                }
                .disabled(self.currentPhotoIndex == 0)
                Button {
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)
                    print(self.currentPhotoIndex)
                    self.currentPhotoIndex += 1
                    print(self.currentPhotoIndex)
                    self.currentLocationManager.centerMapOnPin(location:
                                                                self.journey.photosLocations[currentPhotoIndex])
                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.currentPhotoIndex + 1)}) ??
                    self.currentLocationManager.mapView.userLocation
                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)

                }label: {
                    MapButton(imageName: Icons.arrowRight)
                }
                .disabled(self.currentPhotoIndex == self.journey.numberOfPhotos - 1)
            }
        }
    }
}
