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
    @Binding var highlightedPhotoIndex: Int
    @Binding var showPicture: Bool
    @Binding var highlightedPhoto: UIImage
    var photos: [SinglePhoto]
    var gold: Color {
        Color(uiColor: Colors.premiumColor)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: self.photos.sorted{$1.number > $0.number}.map{$0.photo}[self.highlightedPhotoIndex])
                .resizable()
                .scaledToFill()
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.width > 0
                            && abs(value.translation.width) > abs(value.translation.height)
                            && self.highlightedPhotoIndex > 0 {
                            self.highlightedPhotoIndex -= 1
                            self.highlightedPhoto = self.photos[highlightedPhotoIndex].photo
                        } else if value.translation.width < 0
                                    && abs(value.translation.width) > abs(value.translation.height)
                                    && self.highlightedPhotoIndex < self.photos.count - 1 {
                            self.highlightedPhotoIndex += 1
                            self.highlightedPhoto = self.photos[highlightedPhotoIndex].photo
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
                
                Text(String(self.highlightedPhotoIndex + 1))
                    .foregroundColor(Color(Colors.systemImageColor ?? .white))
                    .font(.system(size: 40))
                Spacer()
                Button {
                    CommunicationManager.sendPhotoViaSocialMedia(image: self.photos[self.highlightedPhotoIndex].photo)
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
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    @Binding var photos: [SinglePhoto]
    
    var layout: [GridItem]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            //This container generates a grid with two columns of journey's images.
            LazyVGrid(columns: self.layout, spacing: 0) {
                ForEach(self.photos.sorted{$1.number > $0.number}, id: \.self.number) { photo in
                    ZStack {
                        Image(uiImage: photo.photo)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(7)
                            .padding(.vertical, 5)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: FloatConstants.shortAnimationDuration)) {
                                    self.photoIndex = photo.number
                                    self.highlightedPhoto = self.photos[photoIndex].photo
                                    self.showPicture = true
                                }
                            }
                    }
                }
            }
        }
        .opacity(self.showPicture ? 0 : 1)
    }
    
    func resetPhotosNumeration() {
        var annotationIndex = 1
        
        self.currentLocationManager.mapView.annotations.filter({ $0.title != "My Location" }).forEach { annotation in
            let newAnnotation = MKPointAnnotation()
            newAnnotation.title = String(annotationIndex)
            newAnnotation.coordinate = annotation.coordinate
            self.currentLocationManager.mapView.removeAnnotation(annotation)
            self.currentLocationManager.mapView.addAnnotation(newAnnotation)
            annotationIndex += 1
        }
        
        for number in 0...self.photos.count - 1 {
            self.photos[number].number = number
        }
        
        for number in 0...self.currentImages.count - 1 {
            self.currentImages[number].id = Int16(number)
        }
    }
}

//Struct contains code responsible for generating a single annotation view on one of two maps.
struct PhotoAnnotationView: View {
    
    //Variables are described in SumUpView struct.
    @Binding var photoIndex: Int
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
                        self.photoIndex = self.location.id
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
