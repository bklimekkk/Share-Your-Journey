//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 11/01/2023.
//

import Foundation
import SwiftUI

struct ImagesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    @Binding var takeAPhoto: Bool
    @State var showPhotoDetails = false
    var currentLocationManager: CurrentLocationManager
    var numberOfPhotos: Int
    var layout: [GridItem]
    var singleJourney: SingleJourney

    var body: some View {
        NavigationView {
            VStack {
                if self.numberOfPhotos == 0 {
                    VStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Text("The journey is empty")
                            if self.takeAPhoto {
                                ProgressView()
                            } else {
                                Button("Take a photo") {
                                    self.takeAPhoto = true
                                    self.dismiss()
                                }
                            }
                        }
                        Spacer()
                    }
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button{
                                self.dismiss()
                            }label:{
                                SheetDismissButtonView()
                            }
                        }
                    }
                } else {
                    ZStack {
                        ImagesGrid(showPicture: self.$showPicture,
                                   photoIndex: self.$photoIndex,
                                   highlightedPhoto: self.$highlightedPhoto,
                                   layout: self.layout,
                                   singleJourney: self.singleJourney)
                        HighlightedPhoto(highlightedPhotoIndex: self.$photoIndex,
                                         showPicture: self.$showPicture,
                                         highlightedPhoto: self.$highlightedPhoto,
                                         journey: self.singleJourney)
                    }
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button{
                                self.dismiss()
                            }label:{
                                SheetDismissButtonView()
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button(UIStrings.viewInTheMap) {
                                    self.showPicture = false
                                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                                           animated: true)
                                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.photoIndex + 1)}) ??
                                    self.currentLocationManager.mapView.userLocation
                                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                                    self.dismiss()
                                }
                                Button(UIStrings.checkInfo) {
                                    self.showPhotoDetails = true
                                }
                            } label: {
                                Image(systemName: Icons.ellipsisCircle)
                            }
                        }
                    }
                    .sheet(isPresented: $showPhotoDetails) {
                        PhotoDetailsView(photo: self.singleJourney.photos[self.photoIndex])
                    }
                }
            }
            .navigationTitle(UIStrings.currentJourneyImages)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
