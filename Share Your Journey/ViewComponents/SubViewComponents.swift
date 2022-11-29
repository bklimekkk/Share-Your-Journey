//
//  SubViewComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import SwiftUI

//Struct contains code that generates enlarged photo picked by user.
struct HighlightedPhoto: View {
    
    //Variables described in SeeJourneyView struct.
    @Binding var savedToCameraRoll: Bool
    @Binding var highlightedPhotoIndex: Int
    @Binding var showPicture: Bool
    @Binding var highlightedPhoto: UIImage
    @Binding var subscriber: Bool
    @Binding var showPanel: Bool
    var journey: SingleJourney
    var gold: Color {
        Color(uiColor: UIColor(red: 0.90, green: 0.42, blue: 0.00, alpha: 1.00))
    }
    
    var body: some View {
        if self.showPicture {
            VStack {
                Image(uiImage: self.journey.photos.sorted{$1.number > $0.number}.map{$0.photo}[self.highlightedPhotoIndex])
                    .resizable()
                    .scaledToFit()
                //Gesture added to the image makes it possible to drag left or right to skip to the next or previous image.
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.width > 0 && self.highlightedPhotoIndex > 0 {
                                self.highlightedPhotoIndex -= 1
                                self.highlightedPhoto = self.journey.photos[highlightedPhotoIndex].photo
                                self.savedToCameraRoll = false
                            }
                            if value.translation.width < 0 && self.highlightedPhotoIndex < self.journey.photos.count - 1 {
                                self.highlightedPhotoIndex += 1
                                self.highlightedPhoto = self.journey.photos[highlightedPhotoIndex].photo
                                self.savedToCameraRoll = false
                            }
                        }))
            
                Spacer()
                //This HStack contains code responsible for generating functionality provided along with highlighted image: Ability to go back to the map, number of image and ability to download the image.
                HStack {
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            self.showPicture = false
                            self.savedToCameraRoll = false
                        }
                    } label:{
                        Image(systemName: "xmark")
                            .font(.system(size: 30))
                            .foregroundColor(Color(UIColor(named:"SystemImageColor") ?? .gray))
                    }
                    
                    Spacer()
                    
                    Text(String(self.highlightedPhotoIndex + 1))
                        .foregroundColor(Color(UIColor(named:"SystemImageColor") ?? .white))
                        .font(.system(size: 40))
                    
                    Spacer()
                    
                    //While the image is highlighted, users can download it only once, after clicking the button, it disappears.
                    if self.savedToCameraRoll {
                        Button {} label:{
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                                .offset(y: -5)
                        }
                        .disabled(true)
                    } else {
                        Button {
                            
                            if self.subscriber {
                                UIImageWriteToSavedPhotosAlbum(self.highlightedPhoto, nil, nil, nil)
                            withAnimation {
                                self.savedToCameraRoll = true
                            }
                            } else {
                                self.showPanel = true
                            }
                            
                        } label:{
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 30))
                                .foregroundColor(self.subscriber ? Color(UIColor(named:"SystemImageColor") ?? .gray) : self.gold)
                                .offset(y: -5)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .transition(.scale)
            .zIndex(1)
        }
    }
}

//struct contains code that generates list of photos presented if the first option in triple picker is chosen.
struct PhotosAlbumView: View {
    
    //Variables are described in SumUpView struct.
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    var layout: [GridItem]
    var singleJourney: SingleJourney
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            //This container generates a grid with two columns of journey's images.
            LazyVGrid(columns: self.layout, spacing: 0) {
                ForEach(self.singleJourney.photos.sorted{$1.number > $0.number}, id: \.self.number) { photo in
                    Image(uiImage: photo.photo)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                self.photoIndex = photo.number
                                self.highlightedPhoto = self.singleJourney.photos[photoIndex].photo
                                self.showPicture = true
                            }
                        }
                }
            }
        }
        .opacity(self.showPicture ? 0 : 1)
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
                    withAnimation(.easeInOut(duration: 0.15)) {
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
