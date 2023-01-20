//
//  StartView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 09/02/2022.
//

import SwiftUI
import MapKit
import RevenueCat

//Struct responsible for presenting users with screen enabling users to start a journey.

class WeatherController: ObservableObject {
    @Published var showWeather = false
    @Published var expandWeather = false
    @Published var weatherLatitude = 0.0
    @Published var weatherLongitude = 0.0
}

class JourneyStateController: ObservableObject {
    //Variable defines if journey was paused.
    @Published  var paused = false
    //Variable responsible for defining if journey has finished. If yes, application is responsible for showing sum up screen.
    @Published var showSumUp = false
    //object responsible for holding data about user's current location.
    @Published var currentLocation: MKCoordinateRegion!
    //Variable's value justifies if user wants to take a photo at a particular moment.
    @Published var takeAPhoto = false
    //Variable justifies if the user decided to go back from the sum-up screen to make changes to the current journey.
    @Published var goBack = false
    @Published var showSettings = false
    @Published var showImages = false
    //Variable's value justifies if user wants to pick image from the gallery instead of taking a photo.
    @Published var pickAPhoto = false
    @Published var walking = false
    //Variables responsible for showing potential journey error messages.
    @Published var alertError = false
    @Published var alertMessage = false
    @Published var loadCamera = false
    @Published var alertBody = UIStrings.emptyString
}

class CurrentImagesCollection: ObservableObject {
    @Published var photoIndex = 0
    @Published var highlightedPhoto: UIImage = UIImage()
    @Published var showPicture: Bool = false
    @Published var savedToCameraRoll: Bool = false
    @Published var layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
}

struct StartView: View {
    @FetchRequest(sortDescriptors: []) var currentImages: FetchedResults<CurrentImage>
    @FetchRequest(sortDescriptors: []) var currentLocations: FetchedResults<CurrentLocation>
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    //Emum justifies if users want to finish the journey and see where they went or completely quit it without intention of viewing or saving it.
    enum AlertType {
        case finish
        case quit
    }
    //Value of the variable is set to AlertType enum value.
    @State private var alert = AlertType.finish
    
    //Varieble's value justifies if users are currently logged in or not.
    @AppStorage("loggedOut") private var loggedOut = true
    //Variable defines if journey was started.
    @AppStorage("startedJourney") private var startedJourney = false
    
    //Array is prepared to contain all objects representing photos taken by user during the journey.
    @State private var arrayOfPhotos: [SinglePhoto] = []
    //Array is prepared to contain all objects representing lcations where photos were taken during the journey.
    @State private var arrayOfPhotosLocations: [CLLocationCoordinate2D] = []
    
    //Variable responsible for defining if journey has finished. If yes, application is responsible for showing sum up screen.

    //Object necessary for tracking user's location.
    @StateObject private var currentLocationManager = CurrentLocationManager()
    @StateObject private var weatherController = WeatherController()
    @StateObject private var journeyStateController = JourneyStateController()
    @StateObject private var currentImagesCollection = CurrentImagesCollection()
    @StateObject private var subscription = Subscription()
    @State private var showPhoto = false
    @State private var photoIndex = 0
    @State private var highlightedPhoto: UIImage = UIImage()
    @State private var showDirections = false
    @State private var routeIsDisplayed = false
    @State private var showInfo = false
    var buttonColor: Color {
        colorScheme == .dark ? .white : .blue
    }
    
    var body: some View {
        ZStack {
            ZStack {
                //This struct contains MapView struct, which means that during they journey, users are able to use 3D map.
                MapView(walking: self.$journeyStateController.walking,
                        showPhoto: self.$showPhoto,
                        photoIndex: self.$photoIndex,
                        showWeather: self.$weatherController.showWeather,
                        showDirections: self.$showDirections,
                        expandWeather: self.$weatherController.expandWeather,
                        weatherLatitude: self.$weatherController.weatherLatitude,
                        weatherLongitude: self.$weatherController.weatherLongitude,
                        routeIsDisplayed: self.$routeIsDisplayed,
                        photosLocations: self.$arrayOfPhotosLocations)
                .environmentObject(self.currentLocationManager)
                .edgesIgnoringSafeArea(.all)

                VStack (spacing: 0) {
                    HStack {
                        Button {
                            self.logOut()
                        } label:{
                            MapButton(imageName: "arrow.backward")
                        }
                        if self.showDirections {
                            DirectionsView(location: self.arrayOfPhotosLocations[self.photoIndex])
                        }
                        Spacer()
                    }
                    .padding(.top, 5)
                    Spacer()
                    HStack {
                        VStack (spacing: 10) {
                            Spacer()
                            if self.routeIsDisplayed {
                                RemoveRouteView(routeIsDisplayed: self.$routeIsDisplayed, currentLocationManager: self.currentLocationManager)
                            }
                            if !self.arrayOfPhotosLocations.isEmpty && self.startedJourney {
                                DirectionIcons(mapType: self.$currentLocationManager.mapView.mapType,
                                               subscriber: self.$subscription.subscriber,
                                               showPanel: self.$subscription.showPanel,
                                               walking: self.$journeyStateController.walking)
                            }
                            Button{
                                self.journeyStateController.showSettings = true
                            } label: {
                                SettingsButton()
                            }
                            .foregroundColor(buttonColor)

                            if self.startedJourney {
                                Button {
                                    self.journeyStateController.showImages = true
                                }label: {
                                    ImageButton()
                                }
                                .foregroundColor(self.buttonColor)
                            }

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
                        if self.arrayOfPhotosLocations.count > 1 {
                            JourneyControlView(numberOfPhotos: self.arrayOfPhotosLocations.count,
                                               currentLocationManager: self.currentLocationManager,
                                               currentPhotoIndex: self.$photoIndex)
                        }
                    }
                    .padding(.bottom, 10)
                    //This else if statements block ensures that starting, pausing, resuming,
                    //quitting and completing the journey works in the most intuitive way.
                    if startedJourney && !journeyStateController.paused {
                        RunningJourneyModeView(paused: $journeyStateController.paused,
                                               pickAPhoto: $journeyStateController.pickAPhoto,
                                               takeAPhoto: $journeyStateController.takeAPhoto,
                                               loadCamera: $journeyStateController.loadCamera,
                                               currentLocationManager: currentLocationManager)
                    } else if startedJourney && journeyStateController.paused {
                        PausedJourneyModeView(arrayOfPhotos: $arrayOfPhotos,
                                              alertMessage: $journeyStateController.alertMessage,
                                              alertError: $journeyStateController.alertError,
                                              paused: $journeyStateController.paused,
                                              startedJourney: $startedJourney, alert: $alert,
                                              alertBody: $journeyStateController.alertBody,
                                              currentLocationManager: currentLocationManager)
                    } else {
                        StartJourneyModeView(startedJourney: self.$startedJourney, currentLocationManager: self.currentLocationManager)
                    }
                }
                .padding(.horizontal, 5)
                .padding(.bottom, 5)
            }
            .opacity(self.showPhoto ? 0 : 1)
            .disabled(self.showPhoto)
            VStack {
                HStack {
                    Spacer()
                    Button(UIStrings.checkInfo) {
                        self.showInfo = true
                    }
                    .padding(.top, 5)
                    .padding(.trailing, 5)
                    .disabled(!self.showPhoto)
                }
                HighlightedPhoto(highlightedPhotoIndex: self.$photoIndex,
                                 showPicture: self.$showPhoto,
                                 highlightedPhoto: self.$highlightedPhoto,
                                 journey: SingleJourney(numberOfPhotos: self.arrayOfPhotosLocations.count,
                                                        photos: self.arrayOfPhotos,
                                                        photosLocations: self.arrayOfPhotosLocations))
            }
            .opacity(self.showPhoto ? 1 : 0)
        }
        .task {
            if !self.currentImages.isEmpty && self.arrayOfPhotos.isEmpty {
                for i in self.currentImages {
                    self.arrayOfPhotos.append(SinglePhoto(date: i.getDate,
                                                          number: i.getId,
                                                          photo: i.getImage,
                                                          location: i.getLocation,
                                                          subLocation: i.getSubLocation,
                                                          administrativeArea: i.getAdministrativeArea,
                                                          country: i.getCountry,
                                                          isoCountryCode: i.getIsoCountryCode,
                                                          name: i.getName,
                                                          postalCode: i.getPostalCode,
                                                          ocean: i.getOcean,
                                                          inlandWater: i.getInlandWater,
                                                          areasOfInterest: i.getAreasOfInterst.components(separatedBy: ",")))
                }
            }
            
            if !self.currentLocations.isEmpty && self.arrayOfPhotosLocations.isEmpty {
                for i in self.currentLocations {
                    self.arrayOfPhotosLocations.append(CLLocationCoordinate2D(latitude: i.latitude, longitude: i.longitude))
                }
            }

            var index = 0
            while index < self.arrayOfPhotosLocations.count {
                let photoPin = MKPointAnnotation()
                photoPin.title = String(index + 1)
                photoPin.coordinate = self.arrayOfPhotosLocations[index]
                self.currentLocationManager.mapView.addAnnotation(photoPin)
                index += 1
            }
        }
        .sheet(isPresented: self.$showInfo, content: {
            PhotoDetailsView(photo: self.arrayOfPhotos[self.photoIndex])
        })
        .fullScreenCover(isPresented: self.$journeyStateController.showSettings, content: {
            SettingsView(loggedOut: $loggedOut)
        })
        .fullScreenCover(isPresented: self.$journeyStateController.showImages, content: {
            ImagesView(showPicture: self.$currentImagesCollection.showPicture,
                       photoIndex: self.$currentImagesCollection.photoIndex,
                       highlightedPhoto: self.$currentImagesCollection.highlightedPhoto,
                       takeAPhoto: self.$journeyStateController.takeAPhoto,
                       currentLocationManager: self.currentLocationManager,
                       numberOfPhotos: self.$arrayOfPhotosLocations.count,
                       layout: self.currentImagesCollection.layout,
                       singleJourney: SingleJourney(numberOfPhotos: self.arrayOfPhotosLocations.count,
                                                    photos: self.arrayOfPhotos,
                                                    photosLocations: self.arrayOfPhotosLocations))
        })
        .fullScreenCover(isPresented: self.$subscription.showPanel, content: {
            SubscriptionView(subscriber: self.$subscription.subscriber)
        })
        .fullScreenCover(isPresented: self.$loggedOut) {
            //If user isn't logged in, screen presented by StartView struct is fully covered by View generated by this struct.
            LoginView(loggedOut: self.$loggedOut)
        }
        .fullScreenCover(isPresented: self.$journeyStateController.takeAPhoto, onDismiss: {
            //Photo's location is added to the aproppriate array after view with camera is dismissed.
            withAnimation {
                self.addPhotoLocation()
            }
            if self.moc.hasChanges {
                try? self.moc.save()
            }
        }, content: {
            //Struct represents view that user is supposed to see while taking a picture.
            PhotoPickerView(pickPhoto: $journeyStateController.pickAPhoto, photosArray: $arrayOfPhotos)
                .onAppear {
                    self.journeyStateController.loadCamera = false
                }
                .ignoresSafeArea()
        })

        //After the journey is finished, StartView is coverd by SumUpView.
        .fullScreenCover(isPresented: self.$journeyStateController.showSumUp, onDismiss: {
            if !self.journeyStateController.goBack {
                self.currentLocationManager.mapView.removeAnnotations(self.currentLocationManager.mapView.annotations)
                self.startedJourney = false
                self.journeyStateController.paused = false
                self.arrayOfPhotos = []
                self.arrayOfPhotosLocations = []
                for i in self.currentImages {
                    self.moc.delete(i)
                }
                for i in self.currentLocations {
                    self.moc.delete(i)
                }
                if self.moc.hasChanges {
                    try? self.moc.save()
                }
            } else {
                self.journeyStateController.paused = false
                self.journeyStateController.goBack = false
            }
        }) {
            SumUpView(journey: SingleJourney(numberOfPhotos: self.arrayOfPhotos.count,
                                             photos: self.arrayOfPhotos,
                                             photosLocations: self.arrayOfPhotosLocations),
                      showSumUp: self.$journeyStateController.showSumUp,
                      goBack: self.$journeyStateController.goBack, previousLocationManager: self.currentLocationManager)
        }
        //Alert is presented only if error occurs
        .alert(UIStrings.noPhotos, isPresented: self.$journeyStateController.alertError) {
            Button(UIStrings.ok, role: .cancel) {
                self.journeyStateController.alertMessage = false
            }
        } message: {
            Text(self.journeyStateController.alertBody)
        }
        //Alert is presented after user chooses to finish the journey. They have two ways of doing it and depending on which one they choose, alert will be looking differently.
        .alert(isPresented: self.$journeyStateController.alertMessage) {
            Alert(title: Text(self.alert == .finish ? UIStrings.finishJourney : UIStrings.deleteJourney),
                  message: Text(self.alert == .finish ? UIStrings.areYouSureToFinish : UIStrings.areYouSureToDelete),
                  primaryButton: .destructive(Text(UIStrings.cancel)) {
                self.journeyStateController.alertMessage = false
            },
                  secondaryButton: .default(Text(UIStrings.yes)) {
                if self.alert == .finish {
                    self.finishJourney()
                } else {
                    self.alert = .finish
                    for i in self.currentImages {
                        self.moc.delete(i)
                    }
                    for i in self.currentLocations {
                        self.moc.delete(i)
                    }
                    self.quitJourney()
                }
                if self.moc.hasChanges {
                    try? self.moc.save()
                }
                self.journeyStateController.alertMessage = false
            })
        }
        //When users see main screen for the first time, application updates user's current location.
        .onAppear(perform: {
            self.journeyStateController.currentLocation = self.currentLocationManager.currentRegion
        })
    }
    
    /**
     Function is responsible for populating array with location objects with object containing the right photo location.
     */
    func addPhotoLocation() {
        if self.arrayOfPhotosLocations.count < self.arrayOfPhotos.count {
            self.journeyStateController.currentLocation = self.currentLocationManager.currentRegion
            self.arrayOfPhotosLocations.append(self.journeyStateController.currentLocation.center)
            let location = CurrentLocation(context: self.moc)
            location.latitude = self.journeyStateController.currentLocation.center.latitude
            location.longitude = self.journeyStateController.currentLocation.center.longitude

            guard let lastPhoto = self.arrayOfPhotos.last else {
                return
            }

            let image = CurrentImage(context: self.moc)
            image.id = Int16(lastPhoto.number)
            image.image = lastPhoto.photo.jpegData(compressionQuality: 0.5)

            let locationCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            SpotDetailsManager().calculatePlace(locationCoordinate: locationCoordinate) { placemark in
                let locality = placemark?.locality ?? UIStrings.emptyString
                let subLocality = placemark?.subLocality ?? UIStrings.emptyString
                let administrativeArea = placemark?.administrativeArea ?? UIStrings.emptyString
                let country = placemark?.country ?? UIStrings.emptyString
                let isoCountryCode = placemark?.isoCountryCode ?? UIStrings.emptyString
                let name = placemark?.name ?? UIStrings.emptyString
                let postalCode = placemark?.postalCode ?? UIStrings.emptyString
                let ocean = placemark?.ocean ?? UIStrings.emptyString
                let inlandWater = placemark?.inlandWater ?? UIStrings.emptyString
                let areasOfInterest = placemark?.areasOfInterest?.joined(separator: ",") ?? UIStrings.emptyString
                let date = Date()
                let currentPhotoIndex = self.arrayOfPhotos.count - 1
                self.arrayOfPhotos[currentPhotoIndex].date = date
                self.arrayOfPhotos[currentPhotoIndex].location = locality
                self.arrayOfPhotos[currentPhotoIndex].subLocation = subLocality
                self.arrayOfPhotos[currentPhotoIndex].administrativeArea = administrativeArea
                self.arrayOfPhotos[currentPhotoIndex].country = country
                self.arrayOfPhotos[currentPhotoIndex].isoCountryCode = isoCountryCode
                self.arrayOfPhotos[currentPhotoIndex].name = name
                self.arrayOfPhotos[currentPhotoIndex].postalCode = postalCode
                self.arrayOfPhotos[currentPhotoIndex].ocean = ocean
                self.arrayOfPhotos[currentPhotoIndex].inlandWater = inlandWater
                self.arrayOfPhotos[currentPhotoIndex].areasOfInterest = areasOfInterest.components(separatedBy: ",")
                image.date = date
                image.location = locality
                image.subLocation = subLocality
                image.administrativeArea = administrativeArea
                image.country = country
                image.isoCountryCode = isoCountryCode
                image.name = name
                image.postalCode = postalCode
                image.ocean = ocean
                image.inlandWater = inlandWater
                image.areasOfInterest = areasOfInterest
            }
            let photoPin = MKPointAnnotation()
            photoPin.title = String(self.arrayOfPhotosLocations.count)
            photoPin.coordinate = self.arrayOfPhotosLocations[self.arrayOfPhotosLocations.count - 1]
            self.currentLocationManager.mapView.addAnnotation(photoPin)
            self.currentLocationManager.mapView.selectAnnotation(photoPin, animated: true)
        }
    }
    
    /**
     Function uses firebase's signOut function in order to log the user out from the system.
     */
    func logOut() {
        do {
            try FirebaseSetup.firebaseInstance.auth.signOut()
        } catch let signOutError as NSError {
            print("Error while logging out: \(signOutError)")
        }
        
        Purchases.shared.logOut { customerInfo, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        self.loggedOut = true
    }
    
    /**
     Function responsible for resuming the journey activity.
     */
    func finishJourney() {
        self.journeyStateController.showSumUp = true
    }
    
    /**
     Function responsible for quiting the journey activity.
     */
    func quitJourney() {
        self.currentLocationManager.recenterLocation()
        self.currentLocationManager.mapView.removeAnnotations(self.currentLocationManager.mapView.annotations)
        self.currentLocationManager.mapView.removeOverlays(self.currentLocationManager.mapView.overlays)
        self.arrayOfPhotos = []
        self.arrayOfPhotosLocations = []
        self.startedJourney = false
        self.journeyStateController.paused = false
    }
}

struct SettingsButton: View {
    var body: some View {
        MapButton(imageName: Icons.gearshapeFill)
    }
}
