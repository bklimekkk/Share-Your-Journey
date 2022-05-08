//
//  SumUpView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 18/02/2022.
//

import SwiftUI
import MapKit

//Extension informs the program how CLLocationCoordinate2D objects should be sorted.
extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

//Struct contains code that generates screen that users see after finishing the journey.
struct SumUpView: View {
    
    //this layout variable ensures that photo albums contains 2 columns of photos.
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    //this variable controls which of three modes program should currently display.
    @State private var viewType = SeeJourneyView.ViewType.twoDimensional
    
    //variable represents the journey user has taken before sum-up screen appeared.
    var singleJourney: SingleJourney
    
    //This variable controls if this sum up view is presented or not.
    var sumUpPresented: () -> ()
    
    
    //Variables are set to false and are never changed in this struct. They are used to be passed as parameters for MapView.
    @State var walking = false
    @State var done = false
    
    //Index of image that is currently enlarged in the application.
    @State var photoIndex = 0
    
    //Location manager used for the current view (each view with map is supposed to have it's own lcation manager).
    @StateObject private var currentLocationManager = CurrentLocationManager()
    
    //Variable representing user's current location. Right now it's set to one default value, but it is changed right after the view appears.
    @State private var currentLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), latitudinalMeters: 1000, longitudinalMeters: 1000)
    
    //Variable controls if journey should be saved or not.
    @State var saveJourney = false
    
    //Variable controls if viewed image should be saved to camera roll.
    @State private var savedToCameraRoll = false
    
    //Variable controls if users tapped any picture. If yes, it's set to true and the image is enlarged.
    @State private var showPicture = false
    
    //Variable contains data of image that should be enlarged at particular moment.
    @State private var highlightedPhoto: UIImage = UIImage()
    
    //Variable controls where map centers when the sum up views appeares.
    @State private var initialFocus = MKCoordinateRegion(center: CLLocationCoordinate2D(), latitudinalMeters: 1000, longitudinalMeters: 1000)
    
    //Variables checks if all photos were downloaded to phone's camera roll.
    @State private var downloadedPhotos = false
    var body: some View {
        
        if viewType == .photoAlbum {
            TriplePickerView(choice: $viewType, firstChoice: "2D", secondChoice: "3D", thirdChoice: "Album")
                .padding(.horizontal)
                .padding(.top)
            ZStack {
                VStack {
                    if !downloadedPhotos {
                        
                        //Button used to download all journey images.
                        DownloadGalleryButton(journey: singleJourney, showPicture: $showPicture, downloadedPhotos: $downloadedPhotos)
                            .padding(.horizontal, 10)
                    }
                    
                    //List containing all photos.
                    PhotosAlbumView(showPicture: $showPicture, photoIndex: $photoIndex, highlightedPhoto: $highlightedPhoto, layout: layout, singleJourney: singleJourney)
                        .padding(.horizontal, 15)
                }
                
                //This structs is visible only when user chooses to enlarg any photo.
                HighlightedPhoto(savedToCameraRoll: $savedToCameraRoll, highlightedPhotoIndex: $photoIndex, showPicture: $showPicture, highlightedPhoto: $highlightedPhoto, journey: singleJourney)
            }
        } else {
            
            //As users have 3 options of viewing photos, they are presented with picker that contains three values to choose.
            TriplePickerView(choice: $viewType, firstChoice: "2D", secondChoice: "3D", thirdChoice: "Album")
                .padding(.horizontal)
                .padding(.top)
            
            ZStack {
                
                //Depending on option chosen by users, program will present them with different type of map (or photo album).
                if viewType == .threeDimensional {
                    MapView(walking: $walking, showPhoto: $showPicture, photoIndex: $photoIndex, photos: singleJourney.photos.sorted{$1.number > $0.number}.map{$0.photo}, photosLocations: singleJourney.photosLocations)
                        .edgesIgnoringSafeArea(.all)
                        .environmentObject(currentLocationManager)
                        .opacity(showPicture ? 0 : 1)
                } else if viewType == .twoDimensional {
                    Map(coordinateRegion: $initialFocus, annotationItems: singleJourney.photosLocations.enumerated().map({return PhotoLocation(id: $0.offset, location: CLLocationCoordinate2D(latitude: $0.element.latitude, longitude: $0.element.longitude))})) { location in
                        MapAnnotation(coordinate: location.location) {
                            PhotoAnnotationView(photoIndex: $photoIndex, highlightedPhoto: $highlightedPhoto , showPicture: $showPicture, singleJourney: singleJourney, location: location)
                        }
                    }
                    .onAppear {
                        
                        //Variable's center property is set to location of first journey's photo.
                        initialFocus = MKCoordinateRegion(center: singleJourney.photosLocations[0], latitudinalMeters: 1000, longitudinalMeters: 1000)
                    }
                    .opacity(showPicture ? 0 : 1)
                    .ignoresSafeArea()
                }
                VStack {
                    Spacer()
                    VStack {
                        if !showPicture && viewType == .threeDimensional {
                            HStack {
                                VStack {
                                    DirectionIcons(walking: $walking)
                                    MapButtonsView(currentLocationManager: currentLocationManager)
                                }
                                Spacer()
                            }
                        }
                        
                        if !showPicture {
                            if done {
                                Button {
                                    sumUpPresented()
                                } label: {
                                    
                                    //Button is shown only if the journey is saved.
                                    ButtonView(buttonTitle: "Done")
                                }
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                            } else {
                                SumUpFunctionalityButtonsView(saveJourney: $saveJourney, sumUpPresented: sumUpPresented)
                            }
                        }
                    }
                }
                .padding()
                
                HighlightedPhoto(savedToCameraRoll: $savedToCameraRoll, highlightedPhotoIndex: $photoIndex, showPicture: $showPicture, highlightedPhoto: $highlightedPhoto, journey: singleJourney)
            }
            .sheet(isPresented: $saveJourney, onDismiss: {}, content: {
                SaveJourneyView(presentSheet: $saveJourney, done: $done, journey: singleJourney)
            })
        }
    }
}
