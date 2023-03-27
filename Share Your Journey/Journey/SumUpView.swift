//
//  SumUpView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 18/02/2022.
//

import SwiftUI
import MapKit
import Firebase
import RevenueCat

//Struct contains code that generates screen that users see after finishing the journey.
struct SumUpView: View {
    @StateObject var subscription = Subscription()
    
    //this layout variable ensures that photo albums contains 2 columns of photos.
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    //this variable controls which of three modes program should currently display.
    @State private var viewType = ViewType.photoAlbum
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
    @State private var showDirections = false
    @State private var routeIsDisplayed = false
    @State private var showInfo = false

    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .blue
    }
    
    @Binding var showSumUp: Bool
    @Binding var goBack: Bool
    var previousLocationManager: CurrentLocationManager

    var body: some View {
        NavigationView {
            VStack {





                if self.showPicture {
                    HighlightedPhoto(highlightedPhotoIndex: self.$photoIndex,
                                     showPicture: self.$showPicture,
                                     highlightedPhoto: self.$highlightedPhoto,
                                     photos: self.journey.photos)
                } else {
                    VStack {
                        JourneyPickerView(choice: self.$viewType, firstChoice: UIStrings.album, secondChoice: UIStrings.map)
                            .onChange(of: self.viewType, perform: { newValue in
                                if newValue == .threeDimensional {
                                    self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                                           animated: true)
                                    let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.photoIndex + 1)}) ??
                                    self.currentLocationManager.mapView.userLocation
                                    self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                                }
                            })
                            .padding(.horizontal, 5)
                        if self.viewType == .photoAlbum {
                            VStack {
                                if !self.downloadedPhotos {
                                    //Button used to download all journey images.
                                    DownloadGalleryButton(journey: self.journey,
                                                          showDownloadAlert: self.$showDownloadAlert,
                                                          showPicture: self.$showPicture)
                                }
                                //List containing all photos.
                                PhotosAlbumView(showPicture: self.$showPicture,
                                                photoIndex: self.$photoIndex,
                                                highlightedPhoto: self.$highlightedPhoto,
                                                layout: layout,
                                                photos: self.journey.photos)
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
                            ZStack {
                                //Depending on option chosen by users, program will present them with different type of map (or photo album).
                                MapView(walking: self.$walking,
                                        showPhoto: self.$showPicture,
                                        photoIndex: self.$photoIndex,
                                        showWeather: self.$showWeather,
                                        showDirections: self.$showDirections,
                                        expandWeather: self.$expandWeather,
                                        weatherLatitude: self.$weatherLatitude,
                                        weatherLongitude: self.$weatherLongitude,
                                        routeIsDisplayed: self.$routeIsDisplayed,
                                        photosLocations: self.journey.photos.map{$0.coordinateLocation})
                                .edgesIgnoringSafeArea(.all)
                                .environmentObject(self.currentLocationManager)
                                .opacity(self.showPicture ? 0 : 1)
                                VStack {
                                    if self.showWeather {
                                        HStack {
                                            if self.expandWeather {
                                                WeatherView(latitude: self.weatherLatitude, longitude: self.weatherLongitude)
                                            } else {
                                                Button {
                                                    withAnimation(.easeInOut(duration: 0.15)) {
                                                        self.expandWeather = true
                                                    }
                                                }label: {
                                                    MapButton(imageName: Icons.cloudSunFill)
                                                        .foregroundColor(self.colorScheme == .light ? .blue : .white)
                                                }
                                                DirectionsView(location: self.journey.photos[self.photoIndex].coordinateLocation)
                                            }
                                            Spacer()
                                        }
                                        .opacity(self.showPicture ? 0 : 1)
                                    }
                                    Spacer()
                                    VStack {
                                        HStack {
                                            VStack (spacing: 10) {
                                                Spacer()
                                                if self.routeIsDisplayed {
                                                    RemoveRouteView(routeIsDisplayed: self.$routeIsDisplayed,
                                                                    currentLocationManager: self.currentLocationManager)
                                                }
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
                                                JourneyControlView(numberOfPhotos: self.journey.photos.count,
                                                                   currentLocationManager: self.currentLocationManager,
                                                                   currentPhotoIndex: self.$photoIndex,
                                                                   mapType: self.$currentLocationManager.mapView.mapType)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 5)
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
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                Button {
                                    self.showSumUp = false
                                    self.dismiss()
                                } label: {
                                    //Button is shown only if the journey is saved.
                                    ButtonView(buttonTitle: UIStrings.done)
                                        .background(Color.green)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                            }
                            .padding(.horizontal, 5)
                            .padding(.bottom, 5)
                        } else {
                            SumUpFunctionalityButtonsView(journey: self.$journey,
                                                          showDeleteAlert: self.$showDeleteAlert,
                                                          done: self.$done, previousLocationManager: self.previousLocationManager)
                        }
                    }
                    .alert(UIStrings.quit, isPresented: $showDeleteAlert) {
                        Button(UIStrings.cancel, role: .cancel){}
                        Button(UIStrings.quit, role: .destructive) {
                            self.showSumUp = false
                        }
                    } message: {
                        Text(UIStrings.areYouSureToQuit)
                    }
                }







            }
            .navigationTitle(UIStrings.sumUp)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if self.showPicture {
                    if !self.done {
                        Menu {
                            Button {
                                self.showInfo = true
                            } label: {
                                HStack {
                                    Text(UIStrings.checkInfo)
                                    Image(systemName: Icons.infoCircle)
                                }
                            }
                            Button {
                                self.goBack = true
                                self.dismiss()
                            } label: {
                                HStack {
                                    Text(UIStrings.continueJourney)
                                    Image(systemName: Icons.arrowLeftCircle)
                                }
                            }
                        } label: {
                            Image(systemName: Icons.ellipsisCircle)
                        }
                    } else {
                        Button {
                            self.showInfo = true
                        } label: {
                            Image(systemName: Icons.infoCircle)
                        }
                    }
                    } else {
                        if !self.done {
                            Button(UIStrings.continueJourney) {
                                self.goBack = true
                                self.dismiss()
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: self.$subscription.showPanel) {
                SubscriptionView(subscriber: self.$subscription.subscriber)
            }
            .sheet(isPresented: self.$sendJourney, content: {
                SendViewedJourneyView(journey: self.journey)
            })
            .sheet(isPresented: self.$showInfo, onDismiss: {

            }, content: {
                PhotoDetailsView(photo: self.journey.photos[self.photoIndex])
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
