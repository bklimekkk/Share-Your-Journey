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
    
    var journey: SingleJourney
    var body: some View {
        
        if showPicture {
            VStack {
                Image(uiImage:  journey.photos.sorted{$1.number > $0.number}.map{$0.photo}[highlightedPhotoIndex])
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .gray, radius: 2)
                //Gesture added to the image makes it possible to drag left or right to skip to the next or previous image.
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.width > 0 && highlightedPhotoIndex > 0 {
                                highlightedPhotoIndex -= 1
                                highlightedPhoto = journey.photos[highlightedPhotoIndex].photo
                                savedToCameraRoll = false
                            }
                            if value.translation.width < 0 && highlightedPhotoIndex < journey.photos.count - 1 {
                                highlightedPhotoIndex += 1
                                highlightedPhoto = journey.photos[highlightedPhotoIndex].photo
                                savedToCameraRoll = false
                            }
                        }))
                
                //This HStack contains code responsible for generating functionality provided along with highlighted image: Ability to go back to the map, number of image and ability to download the image.
                HStack {
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showPicture = false
                            savedToCameraRoll = false
                        }
                    } label:{
                        Image(systemName: "xmark")
                            .font(.system(size: 30))
                            .foregroundColor(Color(UIColor(named:"SystemImageColor") ?? .gray))
                    }
                    
                    Spacer()
                    
                    Text(String(highlightedPhotoIndex + 1))
                        .foregroundColor(Color(UIColor(named:"SystemImageColor") ?? .white))
                        .font(.system(size: 40))
                    
                    Spacer()
                    
                    //While the image is highlighted, users can download it only once, after clicking the button, it turns gray and becomes inactive.
                    if savedToCameraRoll {
                        Button {} label:{
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 30))
                                .foregroundColor(Color.gray)
                                .offset(y: -5)
                        }
                        .disabled(true)
                        
                    } else {
                        Button {
                            UIImageWriteToSavedPhotosAlbum(highlightedPhoto, nil, nil, nil)
                            savedToCameraRoll = true
                        } label:{
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 30))
                                .foregroundColor(Color(UIColor(named:"SystemImageColor") ?? .gray))
                                .offset(y: -5)
                        }
                    }
                }
            }
            .padding()
            .transition(.scale)
            .zIndex(1)
        }
    }
}

//struct contains code that generates list of photos presented if the third option in triple picker is chosen.
struct PhotosAlbumView: View {
    
    //Variables are described in SumUpView struct.
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    var layout: [GridItem]
    var singleJourney: SingleJourney
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            //This container generates a grid with two columns of journey's images. 
            LazyVGrid(columns: layout, spacing: 0) {
                ForEach(singleJourney.photos.sorted{$1.number > $0.number}, id: \.self) { photo in
                    Image(uiImage: photo.photo)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius:10))
                        .shadow(color: .gray, radius: 2)
                        .scaledToFill()
                        .padding(.vertical, 5)
                        .padding(.horizontal, 1)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                photoIndex = photo.number
                                highlightedPhoto = singleJourney.photos[photoIndex].photo
                                showPicture = true
                            }
                        }
                }
            }
        }
        .opacity(showPicture ? 0 : 1)
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
            Image(uiImage: singleJourney.photos[location.id].photo)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .gray, radius: 2)
                .onTapGesture(count: 1) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        photoIndex = location.id
                        highlightedPhoto = singleJourney.photos[location.id].photo
                        showPicture = true
                    }
                }
            Text(String(location.id + 1))
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
        
    }
}
