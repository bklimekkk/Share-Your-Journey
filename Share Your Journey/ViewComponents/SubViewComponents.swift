//
//  SubViewComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import MapKit
import SwiftUI

//Struct contains code that generates enlarged photo picked by user.
struct HighlightedPhoto: View {

    //Variables described in SeeJourneyView struct.
    @Binding var showPicture: Bool
    @Binding var highlightedPhoto: SinglePhoto
    var photos: [SinglePhoto]
    var gold: Color {
        Color(uiColor: Colors.premiumColor)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: self.highlightedPhoto.photo)
                .resizable()
                .scaledToFill()
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        guard let highlightedPhotoIndex = self.photos.firstIndex(where: { $0.photo == self.highlightedPhoto.photo }) else {
                            return
                        }

                        if value.translation.width > 0
                            && abs(value.translation.width) > abs(value.translation.height)
                            && highlightedPhotoIndex > 0 {
                            self.highlightedPhoto = self.photos[highlightedPhotoIndex - 1]
                        } else if value.translation.width < 0
                                    && abs(value.translation.width) > abs(value.translation.height)
                                    && highlightedPhotoIndex < self.photos.count - 1 {
                            self.highlightedPhoto = self.photos[highlightedPhotoIndex + 1]
                        } else if value.translation.height > 0
                                    && abs(value.translation.height) > abs(value.translation.width) {
                            withAnimation(.linear(duration: FloatConstants.shortAnimationDuration)) {
                                self.showPicture = false
                            }
                        }
                    }))

            Spacer()
            //This HStack contains code responsible for generating functionality provided along with highlighted image: Ability to go back to the map, number of image and ability to download the image.
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                        self.showPicture = false
                    }
                } label:{
                    Image(systemName: Icons.xmark)
                        .font(.system(size: 30))
                        .foregroundColor(Color(Colors.systemImageColor ?? .gray))
                }

                Spacer()

                Text(String((self.photos.firstIndex(where: { $0.photo == self.highlightedPhoto.photo }) ?? 0) + 1))
                    .foregroundColor(Color(Colors.systemImageColor ?? .white))
                    .font(.system(size: 40))
                Spacer()
                Button {
                    CommunicationManager.sendPhotoViaSocialMedia(image: self.highlightedPhoto.photo)
                } label:{
                    Image(systemName: Icons.squareAndArrowUp)
                        .font(.system(size: 30))
                        .foregroundColor(Color(Colors.systemImageColor ?? .gray))
                        .offset(y: -5)
                }
            }
            .padding(.horizontal)
        }
        .transition(.scale)
        .zIndex(1)
    }
}

//struct contains code that generates list of photos presented if the first option in triple picker is chosen.
struct PhotosAlbumView: View {
    @EnvironmentObject var currentLocationManager: CurrentLocationManager
    @FetchRequest(sortDescriptors: []) var currentImages: FetchedResults<CurrentImage>
    @Environment(\.managedObjectContext) var moc

    //Variables are described in SumUpView struct.
    @Binding var showPicture: Bool
    @Binding var highlightedPhoto: SinglePhoto
    @Binding var photos: [SinglePhoto]

    var layout: [GridItem]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            //This container generates a grid with two columns of journey's images.
            LazyVGrid(columns: self.layout, spacing: 0) {
                ForEach(self.photos.sorted{$1.date > $0.date}, id: \.self.date) { photo in
                    ZStack {
                        Image(uiImage: photo.photo)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(7)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                                    self.highlightedPhoto = photo
                                    self.showPicture = true
                                }
                            }
                        VStack {
                            HStack {
                                Button {
                                    self.deletePhoto(photo: photo)
                                } label: {
                                    Image(systemName: "xmark.bin.fill")
                                        .foregroundColor(.red)
                                }
                                .padding(5)

                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .opacity(self.showPicture ? 0 : 1)
    }

    func deletePhoto(photo: SinglePhoto) {
        withAnimation {
            guard let annotationToRemove = self.currentLocationManager.mapView.annotations.first(where: { $0.coordinate == photo.coordinateLocation }) else {
                return
            }

            self.currentLocationManager.mapView.removeAnnotation(annotationToRemove)
            self.photos.removeAll(where: { $0.date == photo.date })
            if let image = self.currentImages.first(where: { $0.getDate == photo.date }) {
                self.moc.delete(image)
            }
            if self.moc.hasChanges {
                try? self.moc.save()
            }
        }
    }
}

//Struct contains code responsible for generating a single annotation view on one of two maps.
struct PhotoAnnotationView: View {
    
    //Variables are described in SumUpView struct.
    @Binding var highlightedPhoto: UIImage
    @Binding var showPicture: Bool
    var singleJourney: SingleJourney
    var location: PhotoLocation
    
    var body: some View {
        ZStack {
            ProgressView()
            Image(uiImage: self.singleJourney.photos[location.id].photo)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .shadow(color: .gray, radius: 2)
                .onTapGesture(count: 1) {
                    withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                        self.highlightedPhoto = self.singleJourney.photos[location.id].photo
                        self.showPicture = true
                    }
                }
            Text(String(self.location.id + 1))
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
        
    }
}
