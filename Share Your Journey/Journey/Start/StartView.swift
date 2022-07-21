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
struct StartView: View {
    
    //Emum justifies if users want to finish the journey and see where they went or completely quit it without intention of viewing or saving it.
    enum AlertType {
        case finish
        case quit
    }
    
    //Value of the variable is set to AlertType enum value.
    @State private var alert = AlertType.finish
    
    //Varieble's value justifies if users are currently logged in or not.
    @State private var loggedOut = true
    
    //Variable defines if journey was started.
    @State  var startedJourney = false
    
    //Variable defines if journey was paused.
    @State  var paused = false
    
    //Variables responsible for showing potential error messages.
    @State private var alertError = false
    @State private var alertMessage = false
    @State private var alertBody = ""
    
    //Variable responsible for defining if journey has finished. If yes, application is responsible for showing sum up screen.
    @State private var showSumUp = false
    
    //Object necessary for tracking user's location.
    @StateObject private var currentLocationManager = CurrentLocationManager()
    
    //object responsible for holding data about user's current location.
    @State private var currentLocation: MKCoordinateRegion!
    
    //Variable's value justifies if user wants to take a photo at a particular moment.
    @State private var takeAPhoto = false
    
    //Variable's value justifies if user wants to pick image from the gallery instead of making a photo.
    @State private var pickAPhoto = false
    
    //Array is prepared to contain all objects representing photos taken by user during the journey.
    @State private var arrayOfPhotos: [SinglePhoto] = []
    
    //Array is prepared to contain all objects representing lcations where photos were taken during the journey.
    @State private var arrayOfPhotosLocations: [CLLocationCoordinate2D] = []
    
    //Variables are set to false (and 0) and are never changed in this struct. They are used to be passed as parameters for MapView.
    @State var showPhoto = false
    @State var walking = false
    @State var photoIndex = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showSettings = false
    @State private var showImages = false
    
    var buttonColor: Color {
        colorScheme == .dark || currentLocationManager.mapView.mapType == .hybridFlyover ? .white : .accentColor
    }
    
    var body: some View {
        ZStack {
            
            //This struct contains MapView struct, which means that during they journey, users are able to use 3D map.
            MapView(walking: $walking, showPhoto: $showPhoto, photoIndex: $photoIndex, photos: [], photosLocations: [])
                .environmentObject(currentLocationManager)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button {
                        logOut()
                    } label:{
                        Image(systemName: "arrow.backward.circle.fill")
                            .foregroundColor(buttonColor)
                            .font(.system(size: 38))
                    }
                    Spacer()
                }
                Spacer()
                
                HStack {
                    VStack {
                        Button{
                            showSettings = true
                        } label: {
                            SettingsButton()
                        }
                        .foregroundColor(buttonColor)
                        
                        if startedJourney {
                            Button {
                                showImages = true
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
                if startedJourney && !paused {
                    RunningJourneyModeView(paused: $paused, pickAPhoto: $pickAPhoto, takeAPhoto: $takeAPhoto, currentLocationManager: currentLocationManager)
                    
                } else if startedJourney && paused {
                    PausedJourneyModeView(arrayOfPhotos: $arrayOfPhotos, alertMessage: $alertMessage, alertError: $alertError, paused: $paused, startedJourney: $startedJourney, alert: $alert, alertBody: $alertBody, currentLocationManager: currentLocationManager)
                } else {
                    StartJourneyModeView(startedJourney: $startedJourney, currentLocationManager: currentLocationManager)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showSettings, content: {
            SettingsView(loggedOut: $loggedOut)
        })
        .fullScreenCover(isPresented: $showImages, content: {
            ImagesView(images: $arrayOfPhotos, imagesLocations: $arrayOfPhotosLocations)
        })
        .fullScreenCover(isPresented: $loggedOut) {
            
            //If user isn't logged in, screen presented by StartView struct is fully covered by View generated by this struct.
            LoginView(loggedOut: $loggedOut)
        }
        .fullScreenCover(isPresented: $takeAPhoto, onDismiss: {
            
            //Photo's location is added to the aproppriate array after view with camera is dismissed.
            addPhotoLocation()
        }, content: {
            //Struct represents view that user is supposed to see while taking a picture.
            PhotoPickerView(pickPhoto: $pickAPhoto, photosArray: $arrayOfPhotos)
                .ignoresSafeArea()
        })
        
        //After the journey is finished, StartView is coverd by SumUpView.
        .fullScreenCover(isPresented: $showSumUp, onDismiss: {
            arrayOfPhotos = []
            arrayOfPhotosLocations = []
        }) {
            SumUpView(singleJourney: SingleJourney(email: "", name: "", date: Date(), numberOfPhotos: arrayOfPhotos.count, photos: arrayOfPhotos, photosLocations: arrayOfPhotosLocations),
                      showSumUp: $showSumUp)
        }
        //Alert is presented only if error occurs
        .alert("No photos", isPresented: $alertError) {
            Button("Ok", role: .cancel) {
                alertMessage = false
            }
        } message: {
            Text(alertBody)
        }
        
        //Alert is presented after user chooses to finish the journey. They have two ways of doing it and depending on which one they choose, alert will be looking differently.
        .alert(isPresented: $alertMessage) {
            Alert(title: Text(alert == .finish ? "Finish Journey" : "Delete Journey"),
                  message: Text(alert == .finish ? "Are you sure that you want to finish the journey?" : "Are you sure of deleting this yourney?"),
                  primaryButton: .destructive(Text("Cancel")) {
                alertMessage = false
            },
                  secondaryButton: .default(Text("Yes")) {
                if alert == .finish {
                    finishJourney()
                } else {
                    alert = .finish
                    quitJourney()
                }
                alertMessage = false
            })
        }

        
        //When users see main screen for the first time, application updates user's current location.
        .onAppear(perform: {
            currentLocation = currentLocationManager.currentRegion
        })
    }
    
    /**
     Function is responsible for populating array with location objects with object containing the right photo location.
     */
    func addPhotoLocation() {
        if arrayOfPhotosLocations.count < arrayOfPhotos.count {
            currentLocation = currentLocationManager.currentRegion
            arrayOfPhotosLocations.append(currentLocation.center)
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
        
        loggedOut = true
    }
    
    /**
     Function responsible for resuming the journey activity.
     */
    func finishJourney() {
        withAnimation {
            startedJourney = false
        }
        paused = false
        showSumUp = true
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
        paused = false
    }
}

struct SettingsButton: View {
    var body: some View {
        Image(systemName: "gearshape.fill")
            .font(.system(size: 30))
            .padding(.vertical, 10)
    }
}
