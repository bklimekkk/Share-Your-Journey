//
//  JourneyControlView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 25/12/2022.
//

import SwiftUI

struct JourneyControlView: View {
    var journey: SingleJourney
    var currentLocationManager: CurrentLocationManager
    @Binding var currentPhotoIndex: Int
    var body: some View {
        VStack {
            Spacer()
            HStack {
                PhotosCounterView(number: self.currentPhotoIndex + 1)
                Button{
                    self.currentPhotoIndex -= 1
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)
                    self.currentLocationManager.centerMapOnPin(location:
                                                                self.journey.photosLocations[currentPhotoIndex])
                }label: {
                    MapButton(imageName: Icons.arrowLeft)
                }
                .disabled(self.currentPhotoIndex == 0)
                Button{
                    self.currentPhotoIndex += 1
                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                           animated: true)
                    self.currentLocationManager.centerMapOnPin(location:
                                                                self.journey.photosLocations[currentPhotoIndex])
                }label: {
                    MapButton(imageName: Icons.arrowRight)
                }
                .disabled(self.currentPhotoIndex == self.journey.numberOfPhotos - 1)
            }
        }
    }
}
