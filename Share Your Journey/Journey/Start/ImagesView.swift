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
    @EnvironmentObject var currentLocationManager: CurrentLocationManager
    @Binding var showPicture: Bool
    @Binding var highlightedPhoto: SinglePhoto
    @Binding var takeAPhoto: Bool
    @Binding var photos: [SinglePhoto]
    @State var showPhotoDetails = false
    var numberOfPhotos: Int
    var layout: [GridItem]

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
                            Button {
                                self.dismiss()
                            } label:{
                                SheetDismissButtonView()
                            }
                        }
                    }
                } else {
                    ZStack {
                        ImagesGrid(showPicture: self.$showPicture,
                                   highlightedPhoto: self.$highlightedPhoto,
                                   photos: self.$photos,
                                   layout: self.layout)
                        .environmentObject(currentLocationManager)
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
                            if self.showPicture {
                                Menu {
                                    Button {
                                        self.showPicture = false
                                        self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                                               animated: true)
                                        let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: { $0.title == String((self.photos.firstIndex(of: self.highlightedPhoto) ?? 0) + 1) }) ??
                                        self.currentLocationManager.mapView.userLocation
                                        self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                                        self.dismiss()
                                    } label: {
                                        HStack {
                                            Text(UIStrings.viewInTheMap)
                                            Image(systemName: Icons.map)
                                        }
                                    }
                                    Button {
                                        self.showPhotoDetails = true
                                    } label: {
                                        HStack {
                                            Text(UIStrings.checkInfo)
                                            Image(systemName: Icons.infoCircle)
                                        }
                                    }
                                    Button {
                                        CommunicationManager.sendPhotoViaSocialMedia(image: self.highlightedPhoto.photo)
                                    } label: {
                                        HStack {
                                            Text(UIStrings.sendViaSocialMedia)
                                            Image(systemName: Icons.squareAndArrowUp)
                                        }
                                    }
                                } label: {
                                    Image(systemName: Icons.ellipsisCircle)
                                }
                            } else {
                                Button {
                                    CommunicationManager.sendPhotosViaSocialMedia(images: self.photos.map({$0.photo}))
                                } label: {
                                    Image(systemName: Icons.squareAndArrowUp)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showPhotoDetails) {
                        PhotoDetailsView(photo: self.photos.first(where: { $0.photo == self.highlightedPhoto.photo }) ?? SinglePhoto())
                    }
                }
            }
            .navigationTitle(UIStrings.currentJourneyImages)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
