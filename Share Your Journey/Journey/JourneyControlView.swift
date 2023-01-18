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
    @Binding var currentPhotoIndex: Int
    var body: some View {
        VStack {
            Spacer()
            HStack {
                PhotosCounterView(currentNumber: self.currentPhotoIndex + 1, overallNumber: self.numberOfPhotos)
                Button {
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)
                    self.currentPhotoIndex -= 1
                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.currentPhotoIndex + 1)}) ??
                    self.currentLocationManager.mapView.userLocation
                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                } label: {
                    MapButton(imageName: Icons.arrowLeft)
                }
                .disabled(self.currentPhotoIndex == 0)
                Button {
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)
                    self.currentPhotoIndex += 1
                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.currentPhotoIndex + 1)}) ??
                    self.currentLocationManager.mapView.userLocation
                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)

                }label: {
                    MapButton(imageName: Icons.arrowRight)
                }
                .disabled(self.currentPhotoIndex == self.numberOfPhotos - 1)
            }
        }
    }
}
