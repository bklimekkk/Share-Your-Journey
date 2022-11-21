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
            MapView(walking: $journeyStateController.walking, showPhoto: $showPhoto, photoIndex: $photoIndex, showWeather: $weatherController.showWeather, expandWeather: $weatherController.expandWeather, weatherLatitude: $weatherController.weatherLatitude, weatherLongitude: $weatherController.weatherLongitude, photos: [], photosLocations: [])
                .environmentObject(currentLocationManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button {
                        logOut()
                    } label:{
                        MapButton(imageName: "arrow.backward")
                    }
                    Spacer()
                }
                Spacer()
                
                HStack {
                    VStack {
                        Button{
                            journeyStateController.showSettings = true
                        } label: {
                            SettingsButton()
                        }
                        .foregroundColor(buttonColor)
                        
                        if startedJourney {
                            Button {
                                journeyStateController.showImages = true
                            }label: {
                                ImageButton()
                            }
                            .foregroundColor(buttonColor)
                        }
                        
                        Button {
                            currentLocationManager.changeTypeOfMap()
                        } label: {
                            MapTypeButton()
                        }
                        .foregroundColor(buttonColor)
                        
                        Button {
                            currentLocationManager.recenterLocation()
                        } label: {
                            LocationButton()
                        }
                        .foregroundColor(buttonColor)
                    }
                    
                    Spacer()
                }

                //This else if statements block ensures that starting, pausing, resuming, quitting and completing the journey works in the most intuitive way.
                if startedJourney && !journeyStateController.paused {
                    RunningJourneyModeView(paused: $journeyStateController.paused, pickAPhoto: $journeyStateController.pickAPhoto, takeAPhoto: $journeyStateController.takeAPhoto, currentLocationManager: currentLocationManager)
                    
                } else if startedJourney && journeyStateController.paused {
                    PausedJourneyModeView(arrayOfPhotos: $arrayOfPhotos, alertMessage: $journeyStateController.alertMessage, alertError: $journeyStateController.alertError, paused: $journeyStateController.paused, startedJourney: $startedJourney, alert: $alert, alertBody: $journeyStateController.alertBody, currentLocationManager: currentLocationManager)
                } else {
                    StartJourneyModeView(startedJourney: $startedJourney, currentLocationManager: currentLocationManager)
                }
            }
            .padding()
        }
        .task {
            if !currentImages.isEmpty {
                for i in currentImages {
                    arrayOfPhotos.append(SinglePhoto(number: i.getId, photo: i.getImage))
                }
            }
            
            if !currentLocations.isEmpty {
                for i in currentLocations {
                    arrayOfPhotosLocations.append(CLLocationCoordinate2D(latitude: i.latitude, longitude: i.longitude))
                }
            }
        }
        .fullScreenCover(isPresented: $journeyStateController.showSettings, content: {
            SettingsView(loggedOut: $loggedOut)
        })
        .fullScreenCover(isPresented: $journeyStateController.showImages, content: {

            ZStack {
                VStack {
                    PhotosAlbumView(showPicture: $currentImagesCollection.showPicture, photoIndex: $currentImagesCollection.photoIndex,
                                    highlightedPhoto: $currentImagesCollection.highlightedPhoto,
                                    layout: currentImagesCollection.layout, singleJourney: SingleJourney(email: "", name: "", place: "", date: Date.now,
                                                                                                         numberOfPhotos: arrayOfPhotosLocations.count,
                                                                                                         photos: arrayOfPhotos,
                                                                                                         photosLocations: arrayOfPhotosLocations,
                                                                                                         networkProblem: false))
                    Spacer()
                    Button {
                        dismiss()
                    }label:{
                        Text("Back to journey")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()

                HighlightedPhoto(savedToCameraRoll: $currentImagesCollection.savedToCameraRoll,
                                 highlightedPhotoIndex: $currentImagesCollection.photoIndex, showPicture: $currentImagesCollection.showPicture,
                                 highlightedPhoto: $currentImagesCollection.highlightedPhoto, subscriber: $subscription.subscriber,
                                 showPanel: $subscription.showPanel, journey: SingleJourney(email: "", name: "", place: "", date: Date.now,
                                                                                            numberOfPhotos: arrayOfPhotosLocations.count,
                                                                                            photos: arrayOfPhotos,
                                                                                            photosLocations: arrayOfPhotosLocations,
                                                                                            networkProblem: false))
            }


        })
        .fullScreenCover(isPresented: $loggedOut) {
            
            //If user isn't logged in, screen presented by StartView struct is fully covered by View generated by this struct.
            LoginView(loggedOut: $loggedOut)
        }
        .fullScreenCover(isPresented: $journeyStateController.takeAPhoto, onDismiss: {
            
            //Photo's location is added to the aproppriate array after view with camera is dismissed.
            addPhotoLocation()
            if moc.hasChanges {
                try? moc.save()
            }
        }, content: {
            //Struct represents view that user is supposed to see while taking a picture.
            PhotoPickerView(pickPhoto: $journeyStateController.pickAPhoto, photosArray: $arrayOfPhotos)
                .ignoresSafeArea()
        })
        
        //After the journey is finished, StartView is coverd by SumUpView.
        .fullScreenCover(isPresented: $journeyStateController.showSumUp, onDismiss: {
            if !journeyStateController.goBack {
                withAnimation {
                    startedJourney = false
                }
                
                journeyStateController.paused = false
                
                arrayOfPhotos = []
                arrayOfPhotosLocations = []
                
                for i in currentImages {
                    moc.delete(i)
                }
                
                for i in currentLocations {
                    moc.delete(i)
                }
                
                if moc.hasChanges {
                    try? moc.save()
                }
            } else {
                journeyStateController.paused = false
                journeyStateController.goBack = false
            }
        }) {
            SumUpView(singleJourney: SingleJourney(email: "", name: "", place: "", date: Date(), numberOfPhotos: arrayOfPhotos.count, photos: arrayOfPhotos, photosLocations: arrayOfPhotosLocations),
                      showSumUp: $journeyStateController.showSumUp, goBack: $journeyStateController.goBack)
        }
        //Alert is presented only if error occurs
        .alert("No photos", isPresented: $journeyStateController.alertError) {
            Button("Ok", role: .cancel) {
                journeyStateController.alertMessage = false
            }
        } message: {
            Text(journeyStateController.alertBody)
        }
        
        //Alert is presented after user chooses to finish the journey. They have two ways of doing it and depending on which one they choose, alert will be looking differently.
        .alert(isPresented: $journeyStateController.alertMessage) {
            Alert(title: Text(alert == .finish ? "Finish Journey" : "Delete Journey"),
                  message: Text(alert == .finish ? "Are you sure that you want to finish the journey?" : "Are you sure of deleting this yourney?"),
                  primaryButton: .destructive(Text("Cancel")) {
                journeyStateController.alertMessage = false
            },
                  secondaryButton: .default(Text("Yes")) {
                if alert == .finish {
                    withAnimation {
                        finishJourney()
                    }
                } else {
                    alert = .finish
                    
                    for i in currentImages {
                        moc.delete(i)
                    }
                    
                    for i in currentLocations {
                        moc.delete(i)
                    }
                    
                    quitJourney()
                }
                
                if moc.hasChanges {
                    try? moc.save()
                }
                
                journeyStateController.alertMessage = false
            })
        }
        
        
        //When users see main screen for the first time, application updates user's current location.
        .onAppear(perform: {
            journeyStateController.currentLocation = currentLocationManager.currentRegion
        })
    }
    
    /**
     Function is responsible for populating array with location objects with object containing the right photo location.
     */
    func addPhotoLocation() {
        if arrayOfPhotosLocations.count < arrayOfPhotos.count {
            journeyStateController.currentLocation = currentLocationManager.currentRegion
            arrayOfPhotosLocations.append(journeyStateController.currentLocation.center)
            let location = CurrentLocation(context: moc)
            location.latitude = journeyStateController.currentLocation.center.latitude
            location.longitude = journeyStateController.currentLocation.center.longitude
            
            let image = CurrentImage(context: moc)
            image.id = Int16(arrayOfPhotos[arrayOfPhotos.count - 1].number)
            image.image = arrayOfPhotos[arrayOfPhotos.count - 1].photo.jpegData(compressionQuality: 0.5)
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
        loggedOut = true
    }
    
    /**
     Function responsible for resuming the journey activity.
     */
    func finishJourney() {
        journeyStateController.showSumUp = true
    }
    
    /**
     Function responsible for quiting the journey activity.
     */
    func quitJourney() {
        currentLocationManager.recenterLocation()
        arrayOfPhotos = []
        arrayOfPhotosLocations = []
        withAnimation {
            startedJourney = false
        }
        journeyStateController.paused = false
    }
}

struct SettingsButton: View {
    var body: some View {
        MapButton(imageName: "gearshape.fill")
    }
}
