//
//  SumUpView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 18/02/2022.
//

import SwiftUI
import MapKit
import RevenueCat

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
    @StateObject var subscription = Subscription()
    
    //this layout variable ensures that photo albums contains 2 columns of photos.
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    //this variable controls which of three modes program should currently display.
    @State private var viewType = SeeJourneyView.ViewType.photoAlbum
    //variable represents the journey user has taken before sum-up screen appeared.
    @State var journey: SingleJourney
    //Variables are set to false and are never changed in this struct. They are used to be passed as parameters for MapView.
    @State var walking = false
    @State var done = false
    //Index of image that is currently enlarged in the application.
    @State var photoIndex = 0
    //Location manager used for the current view (each view with map is supposed to have it's own lcation manager).
    @StateObject private var currentLocationManager = CurrentLocationManager()
    //Variable representing user's current location. Right now it's set to one default value, but it is changed right after the view appears.
    @State private var currentLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(), latitudinalMeters: 0, longitudinalMeters: 0)
    //Variable controls if viewed image should be saved to camera roll.
    @State private var savedToCameraRoll = false
    //Variable controls if users tapped any picture. If yes, it's set to true and the image is enlarged.
    @State private var showPicture = false
    //Variable contains data of image that should be enlarged at particular moment.
    @State private var highlightedPhoto: UIImage = UIImage()
    //Variables checks if all photos were downloaded to phone's camera roll.
    @State private var downloadedPhotos = false
    @State private var showDownloadAlert = false
    @State private var showDeleteAlert = false
    @State private var sendJourney = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var showWeather = false
    @State private var expandWeather = false
    @State private var weatherLatitude = 0.0
    @State private var weatherLongitude = 0.0
    
    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .accentColor
    }
    
    @Binding var showSumUp: Bool
    @Binding var goBack: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                if !self.showPicture {
                    VStack {
                        if self.viewType == .photoAlbum {
                            JourneyPickerView(choice: self.$viewType, firstChoice: UIStrings.album, secondChoice: UIStrings.map)
                                .padding(.horizontal, 5)
                            VStack {
                                if !self.downloadedPhotos {
                                    //Button used to download all journey images.
                                    DownloadGalleryButton(journey: self.journey,
                                                          showDownloadAlert: self.$showDownloadAlert,
                                                          showPicture: self.$showPicture,
                                                          subscriber: self.$subscription.subscriber,
                                                          showPanel: self.$subscription.showPanel)
                                }
                                //List containing all photos.
                                PhotosAlbumView(showPicture: self.$showPicture,
                                                photoIndex: self.$photoIndex,
                                                highlightedPhoto: self.$highlightedPhoto,
                                                layout: layout, singleJourney: self.journey)
                                .padding(.horizontal, 5)
                            }
                            .alert(UIStrings.downloadAllImages, isPresented: self.$showDownloadAlert) {
                                Button(UIStrings.cancel, role: .cancel){}
                                Button(UIStrings.download) {
                                    for photo in self.journey.photos.map({return $0.photo}) {

                                        //Each photo is saved to camera roll.
                                        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
                                    }
                                    withAnimation {
                                        self.downloadedPhotos = true
                                    }
                                }
                            } message: {
                                Text(UIStrings.areYouSureToDownload)
                            }
                        } else {

                            //As users have 3 options of viewing photos, they are presented with picker that contains three values to choose.
                            JourneyPickerView(choice: $viewType, firstChoice: UIStrings.album, secondChoice: UIStrings.map)
                                .padding(.horizontal, 5)
                            ZStack {
                                //Depending on option chosen by users, program will present them with different type of map (or photo album).
                                MapView(walking: self.$walking,
                                        showPhoto: self.$showPicture,
                                        photoIndex: self.$photoIndex,
                                        showWeather: self.$showWeather,
                                        expandWeather: self.$expandWeather,
                                        weatherLatitude: self.$weatherLatitude,
                                        weatherLongitude: self.$weatherLongitude,
                                        photos: self.journey.photos.sorted{$1.number > $0.number}.map{$0.photo},
                                        photosLocations: self.journey.photosLocations)
                                .edgesIgnoringSafeArea(.all)
                                .environmentObject(self.currentLocationManager)
                                .opacity(self.showPicture ? 0 : 1)
                                VStack {
                                    Spacer()
                                    VStack {
                                        HStack {
                                            VStack {
                                                DirectionIcons(mapType: self.$currentLocationManager.mapView.mapType,
                                                               subscriber: self.$subscription.subscriber,
                                                               showPanel: self.$subscription.showPanel,
                                                               walking: self.$walking)
                                                Button {
                                                    self.currentLocationManager.changeTypeOfMap()
                                                } label: {
                                                    MapTypeButton()
                                                }
                                                .foregroundColor(self.buttonColor)

                                                Button {
                                                    self.currentLocationManager.recenterLocation()
                                                } label: {
                                                    LocationButton()
                                                }
                                                .foregroundColor(self.buttonColor)
                                            }
                                            Spacer()
                                            if self.journey.numberOfPhotos > 1 {
                                                JourneyControlView(journey: self.journey,
                                                                   currentLocationManager: self.currentLocationManager,
                                                                   currentPhotoIndex: self.$photoIndex)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                            .task {
                                self.photoIndex = 0
                            }
                        }
                        if self.done {
                            HStack(spacing: 10) {
                                Button {
                                    self.sendJourney = true
                                } label: {
                                    //Button is shown only if the journey is saved.
                                    ButtonView(buttonTitle: UIStrings.sendToFriend)
                                        .background(Color.blue)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                Button {
                                    self.showSumUp = false
                                    self.dismiss()
                                } label: {

                                    //Button is shown only if the journey is saved.
                                    ButtonView(buttonTitle: UIStrings.done)
                                        .background(Color.green)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.horizontal, 5)
                            .padding(.bottom, 5)
                        } else {
                            SumUpFunctionalityButtonsView(journey: self.$journey, showDeleteAlert: self.$showDeleteAlert, done: self.$done)
                        }
                    }
                    .alert(UIStrings.quit, isPresented: $showDeleteAlert) {
                        Button(UIStrings.cancel, role: .cancel){}
                        Button(UIStrings.quit, role: .destructive){
                            self.showSumUp = false
                        }
                    } message: {
                        Text(UIStrings.areYouSureToQuit)
                    }
                }
                HighlightedPhoto(savedToCameraRoll: self.$savedToCameraRoll,
                                 highlightedPhotoIndex: self.$photoIndex,
                                 showPicture: self.$showPicture,
                                 highlightedPhoto: self.$highlightedPhoto,
                                 subscriber: self.$subscription.subscriber,
                                 showPanel: self.$subscription.showPanel,
                                 journey: self.journey)
            }
            .navigationTitle(UIStrings.sumUp)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(UIStrings.continueJourney) {
                        self.goBack = true
                        self.dismiss()
                    }
                    .disabled(self.done)
                }
            }
            .fullScreenCover(isPresented: self.$subscription.showPanel) {
                SubscriptionView(subscriber: self.$subscription.subscriber)
            }
            .sheet(isPresented: self.$sendJourney, content: {
                SendViewedJourneyView(journey: self.journey)
            })
            .task {
                Purchases.shared.getCustomerInfo { (customerInfo, error) in
                    if customerInfo!.entitlements[Links.allFeaturesEntitlement]?.isActive == true {
                        self.subscription.subscriber = true
                    }
                }
            }
        }
    }
}
