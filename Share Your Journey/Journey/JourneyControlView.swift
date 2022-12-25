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
                    self.currentLocationManager.centerMapOnPin(location:
                                                                self.journey.photosLocations[currentPhotoIndex])
                }label: {
                    MapButton(imageName: "arrow.left")
                }
                .disabled(self.currentPhotoIndex == 0)
                Button{
                    self.currentPhotoIndex += 1
                    self.currentLocationManager.centerMapOnPin(location:
                                                                self.journey.photosLocations[currentPhotoIndex])
                }label: {
                    MapButton(imageName: "arrow.right")
                }
                .disabled(self.currentPhotoIndex == self.journey.numberOfPhotos - 1)
            }
        }
    }
}
