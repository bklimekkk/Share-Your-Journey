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
    @Published var alertBody = ""
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
    //Variables are set to false (and 0) and are never changed in this struct. They are used to be passed as parameters for MapView.
    @State var showPhoto = false
    @State var photoIndex = 0

    var buttonColor: Color {
        colorScheme == .dark ? .white : .accentColor
    }
    
    var body: some View {
        ZStack {
            
            //This struct contains MapView struct, which means that during they journey, users are able to use 3D map.
            MapView(walking: self.$journeyStateController.walking,
                    showPhoto: self.$showPhoto,
                    photoIndex: self.$photoIndex,
                    showWeather: self.$weatherController.showWeather,
                    expandWeather: self.$weatherController.expandWeather,
                    weatherLatitude: self.$weatherController.weatherLatitude,
                    weatherLongitude: self.$weatherController.weatherLongitude,
                    photos: [],
                    photosLocations: [])
            .environmentObject(self.currentLocationManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button {
                        self.logOut()
                    } label:{
                        MapButton(imageName: "arrow.backward")
                    }
                    Spacer()
                }
                Spacer()
                
                HStack {
                    VStack {
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
                }

                //This else if statements block ensures that starting, pausing, resuming,
                //quitting and completing the journey works in the most intuitive way.
                if startedJourney && !journeyStateController.paused {
                    RunningJourneyModeView(paused: $journeyStateController.paused,
                                           pickAPhoto: $journeyStateController.pickAPhoto,
                                           takeAPhoto: $journeyStateController.takeAPhoto,
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
            .padding()
        }
        .task {
            if !self.currentImages.isEmpty {
                for i in self.currentImages {
                    arrayOfPhotos.append(SinglePhoto(number: i.getId,
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
            
            if !self.currentLocations.isEmpty {
                for i in self.currentLocations {
                    self.arrayOfPhotosLocations.append(CLLocationCoordinate2D(latitude: i.latitude, longitude: i.longitude))
                }
            }
        }
        .fullScreenCover(isPresented: self.$journeyStateController.showSettings, content: {
            SettingsView(loggedOut: $loggedOut)
        })
        .fullScreenCover(isPresented: self.$journeyStateController.showImages, content: {
            ZStack {
                ImagesView(showPicture: self.$currentImagesCollection.showPicture,
                           photoIndex: self.$currentImagesCollection.photoIndex,
                           highlightedPhoto: self.$currentImagesCollection.highlightedPhoto,
                           layout: self.currentImagesCollection.layout,
                               singleJourney: SingleJourney(email: "",
                                                            name: "",
                                                            place: "",
                                                            date: Date.now,
                                                            numberOfPhotos: self.arrayOfPhotosLocations.count,
                                                            photos: self.arrayOfPhotos,
                                                            photosLocations: self.arrayOfPhotosLocations,
                                                            networkProblem: false))
                HighlightedPhoto(savedToCameraRoll: self.$currentImagesCollection.savedToCameraRoll,
                                 highlightedPhotoIndex: self.$currentImagesCollection.photoIndex, showPicture: self.$currentImagesCollection.showPicture,
                                 highlightedPhoto: self.$currentImagesCollection.highlightedPhoto, subscriber: self.$subscription.subscriber,
                                 showPanel: self.$subscription.showPanel, journey: SingleJourney(email: "", name: "", place: "", date: Date.now,
                                                                                                 numberOfPhotos: self.arrayOfPhotosLocations.count,
                                                                                                 photos: self.arrayOfPhotos,
                                                                                                 photosLocations: self.arrayOfPhotosLocations,
                                                                                            networkProblem: false))
            }
        })
        .fullScreenCover(isPresented: self.$loggedOut) {
            //If user isn't logged in, screen presented by StartView struct is fully covered by View generated by this struct.
            LoginView(loggedOut: self.$loggedOut)
        }
        .fullScreenCover(isPresented: self.$journeyStateController.takeAPhoto, onDismiss: {
            //Photo's location is added to the aproppriate array after view with camera is dismissed.
            self.addPhotoLocation()
            if self.moc.hasChanges {
                try? self.moc.save()
            }
        }, content: {
            //Struct represents view that user is supposed to see while taking a picture.
            PhotoPickerView(pickPhoto: $journeyStateController.pickAPhoto, photosArray: $arrayOfPhotos)
                .ignoresSafeArea()
        })
        
        //After the journey is finished, StartView is coverd by SumUpView.
        .fullScreenCover(isPresented: self.$journeyStateController.showSumUp, onDismiss: {
            if !self.journeyStateController.goBack {
                withAnimation {
                    self.startedJourney = false
                }
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
            SumUpView(singleJourney: SingleJourney(email: "",
                                                   name: "",
                                                   place: "",
                                                   date: Date(),
                                                   numberOfPhotos: self.arrayOfPhotos.count,
                                                   photos: self.arrayOfPhotos,
                                                   photosLocations: self.arrayOfPhotosLocations),
                      showSumUp: self.$journeyStateController.showSumUp,
                      goBack: self.$journeyStateController.goBack)
        }
        //Alert is presented only if error occurs
        .alert("No photos", isPresented: self.$journeyStateController.alertError) {
            Button("Ok", role: .cancel) {
                self.journeyStateController.alertMessage = false
            }
        } message: {
            Text(self.journeyStateController.alertBody)
        }
        //Alert is presented after user chooses to finish the journey. They have two ways of doing it and depending on which one they choose, alert will be looking differently.
        .alert(isPresented: self.$journeyStateController.alertMessage) {
            Alert(title: Text(self.alert == .finish ? "Finish Journey" : "Delete Journey"),
                  message: Text(self.alert == .finish ? "Are you sure that you want to finish the journey?" : "Are you sure of deleting this yourney?"),
                  primaryButton: .destructive(Text("Cancel")) {
                self.journeyStateController.alertMessage = false
            },
                  secondaryButton: .default(Text("Yes")) {
                if self.alert == .finish {
                    withAnimation {
                        self.finishJourney()
                    }
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
                print("locality: \(locality)")
                print("subLocality: \(subLocality)")
                print("administrative area: \(administrativeArea)")
                print("areas of interest: \(areasOfInterest)")
                print("country: \(country)")
                print("inland water: \(inlandWater)")
                print("iso country code: \(isoCountryCode)")
                print("name: \(name)")
                print("ocean: \(ocean)")
                print("postal code: \(postalCode)")
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].location = locality
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].subLocation = subLocality
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].administrativeArea = administrativeArea
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].country = country
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].isoCountryCode = isoCountryCode
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].name = name
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].postalCode = postalCode
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].ocean = ocean
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].inlandWater = inlandWater
                self.arrayOfPhotos[self.arrayOfPhotos.count - 1].areasOfInterest = areasOfInterest.components(separatedBy: ",")
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
        self.arrayOfPhotos = []
        self.arrayOfPhotosLocations = []
        withAnimation {
            self.startedJourney = false
        }
        self.journeyStateController.paused = false
    }
}

struct SettingsButton: View {
    var body: some View {
        MapButton(imageName: "gearshape.fill")
    }
}
