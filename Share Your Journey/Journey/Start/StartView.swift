//
//  StartView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 09/02/2022.
//

import SwiftUI
import MapKit
import Firebase
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
    @Published var alertBody = ""
}

class CurrentImagesCollection: ObservableObject {
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
    @State private var deletedAccount = false
    @State private var showLoginViewAfterAccountDeletion = false
    @State private var takePhotoCancelled = false
    var buttonColor: Color {
        colorScheme == .dark ? .white : .blue
    }
    
    var body: some View {
        VStack {





            if self.showPhoto {





                HighlightedPhoto(highlightedPhotoIndex: self.$photoIndex,
                                 showPicture: self.$showPhoto,
                                 highlightedPhoto: self.$highlightedPhoto,
                                 photos: self.arrayOfPhotos)








            } else {


















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
                            photosLocations: self.arrayOfPhotos.map{$0.coordinateLocation})
                    .environmentObject(self.currentLocationManager)
                    .edgesIgnoringSafeArea(.all)

                    VStack (spacing: 0) {
                        HStack {
                            Button {
                                self.logOut()
                            } label:{
                                MapButton(imageName: "arrow.backward")
                            }
                            if self.showDirections && !self.arrayOfPhotos.isEmpty {
                                DirectionsView(location: self.arrayOfPhotos[self.photoIndex].coordinateLocation)
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
                                if !self.arrayOfPhotos.isEmpty && self.startedJourney {
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
                            if self.arrayOfPhotos.count > 1 {
                                JourneyControlView(numberOfPhotos: self.arrayOfPhotos.count,
                                                   currentLocationManager: self.currentLocationManager,
                                                   currentPhotoIndex: self.$photoIndex,
                                                   mapType: self.$currentLocationManager.mapView.mapType)
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

            }





        }
        .task {
            if !self.currentImages.isEmpty && self.arrayOfPhotos.isEmpty {
                self.currentImages.forEach { image in
                    self.arrayOfPhotos.append(SinglePhoto(date: image.getDate,
                                                          photo: image.getImage,
                                                          coordinateLocation: CLLocationCoordinate2D(latitude: image.latitude, longitude: image.longitude),
                                                          location: image.getLocation,
                                                          subLocation: image.getSubLocation,
                                                          administrativeArea: image.getAdministrativeArea,
                                                          country: image.getCountry,
                                                          isoCountryCode: image.getIsoCountryCode,
                                                          name: image.getName,
                                                          postalCode: image.getPostalCode,
                                                          ocean: image.getOcean,
                                                          inlandWater: image.getInlandWater,
                                                          areasOfInterest: image.getAreasOfInterst.components(separatedBy: ",")))
                }
            }

            var index = 0
            while index < self.arrayOfPhotos.count {
                let photoPin = MKPointAnnotation()
                photoPin.title = String(index + 1)
                photoPin.coordinate = self.arrayOfPhotos.map{$0.coordinateLocation}[index]
                self.currentLocationManager.mapView.addAnnotation(photoPin)
                index += 1
            }
        }
        .fullScreenCover(isPresented: self.$journeyStateController.showSettings, onDismiss: {
            if self.showLoginViewAfterAccountDeletion {
                self.loggedOut = true
            }
        }, content: {
            SettingsView(deletedAccount: self.$deletedAccount, showLoginViewAfterAccountDeletion: self.$showLoginViewAfterAccountDeletion)
        })
        .fullScreenCover(isPresented: self.$journeyStateController.showImages, content: {
            ImagesView(showPicture: self.$currentImagesCollection.showPicture,
                       photoIndex: self.$photoIndex,
                       highlightedPhoto: self.$currentImagesCollection.highlightedPhoto,
                       takeAPhoto: self.$journeyStateController.takeAPhoto,
                       photos: self.$arrayOfPhotos,
                       numberOfPhotos: self.$arrayOfPhotos.count,
                       layout: self.currentImagesCollection.layout)
            .environmentObject(self.currentLocationManager)
        })
        .fullScreenCover(isPresented: self.$subscription.showPanel, content: {
            SubscriptionView(subscriber: self.$subscription.subscriber)
        })
        .fullScreenCover(isPresented: self.$loggedOut) {
            //If user isn't logged in, screen presented by StartView struct is fully covered by View generated by this struct.
            LoginView(loggedOut: self.$loggedOut, showLoginViewAfterAccountDeletion: self.$showLoginViewAfterAccountDeletion)
        }
        .fullScreenCover(isPresented: self.$journeyStateController.takeAPhoto, onDismiss: {
            //Photo's location is added to the aproppriate array after view with camera is dismissed.
            withAnimation {
                if !self.takePhotoCancelled {
                    self.addPhotoLocation()
                } else {
                    self.takePhotoCancelled = false
                }
            }
            if self.moc.hasChanges {
                try? self.moc.save()
            }
        }, content: {
            //Struct represents view that user is supposed to see while taking a picture.
            PhotoPickerView(pickPhoto: $journeyStateController.pickAPhoto,
                            takePhotoCancelled: self.$takePhotoCancelled,
                            photosArray: $arrayOfPhotos)
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
                self.currentImages.forEach { image in
                    self.moc.delete(image)
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
                                             photosLocations: self.arrayOfPhotos.map{$0.coordinateLocation}),
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
                    self.currentImages.forEach { image in
                        self.moc.delete(image)
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
        let currentPhotoIndex = self.arrayOfPhotos.count - 1
        self.journeyStateController.currentLocation = self.currentLocationManager.currentRegion
        self.arrayOfPhotos[currentPhotoIndex].coordinateLocation = self.journeyStateController.currentLocation.center

        guard let lastPhoto = self.arrayOfPhotos.last else {
            return
        }

        let image = CurrentImage(context: self.moc)
        image.image = lastPhoto.photo.jpegData(compressionQuality: 0.5)
        image.latitude = self.journeyStateController.currentLocation.center.latitude
        image.longitude = self.journeyStateController.currentLocation.center.longitude

        let locationCoordinate = CLLocationCoordinate2D(latitude: image.latitude, longitude: image.longitude)
        SpotDetailsManager().calculatePlace(locationCoordinate: locationCoordinate) { placemark in
            let locality = placemark?.locality ?? ""
            let subLocality = placemark?.subLocality ?? ""
            let administrativeArea = placemark?.administrativeArea ?? ""
            let country = placemark?.country ?? ""
            let isoCountryCode = placemark?.isoCountryCode ?? ""
            let name = placemark?.name ?? ""
            let postalCode = placemark?.postalCode ?? ""
            let ocean = placemark?.ocean ?? ""
            let inlandWater = placemark?.inlandWater ?? ""
            let areasOfInterest = placemark?.areasOfInterest?.joined(separator: ",") ?? ""
            let date = Date()
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
        photoPin.title = String(self.arrayOfPhotos.count)
        photoPin.coordinate = lastPhoto.coordinateLocation
        self.currentLocationManager.mapView.addAnnotation(photoPin)
        self.currentLocationManager.mapView.selectAnnotation(photoPin, animated: true)
    }
    
    /**
     Function uses firebase's signOut function in order to log the user out from the system.
     */
    func logOut() {
        do {
            try Auth.auth().signOut()
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
        HapticFeedback.heavyHapticFeedback ()
    }
    
    /**
     Function responsible for quiting the journey activity.
     */
    func quitJourney() {
        self.currentLocationManager.recenterLocation()
        self.currentLocationManager.mapView.removeAnnotations(self.currentLocationManager.mapView.annotations)
        self.currentLocationManager.mapView.removeOverlays(self.currentLocationManager.mapView.overlays)
        self.arrayOfPhotos = []
        self.startedJourney = false
        self.journeyStateController.paused = false
    }
}

struct SettingsButton: View {
    var body: some View {
        MapButton(imageName: Icons.gearshapeFill)
    }
}
