//
//  SeeJourneyView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/03/2022.
//

import SwiftUI
import MapKit
import Firebase
import RevenueCat

class Subscription: ObservableObject {
    @Published var subscriber: Bool = false
    @Published var showPanel: Bool = false
}

//Struct contains code responsible for generating screen showing users journey they want to view.
struct SeeJourneyView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    //Similar variable described in SumUpView struct.
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    //Variable controls if users want to receive walking or driving directions.
    @State var walking = false
    //Object necessary for tracking user's location.
    @StateObject private var currentLocationManager = CurrentLocationManager()
    //Variable is set to one of ViewType enum's cases.
    @State private var viewMode = ViewType.photoAlbum
    //journey that is currently viewed by the user.
    @State var journey: SingleJourney
    //all locations that are assigned to photos taken by user.
    @State private var locations: [PhotoLocation] = []
    //Similar variables were described in SumUpView struct.
    @State private var currentPhotoIndex = 0
    @State private var showPicture = false
    @State private var highlightedPhoto: UIImage = UIImage()
    @State private var downloadedPhotos = false
    @State private var showDownloadAlert = false
    //Variable controls if the journey can be found in user's downloaded journeys in the server.
    @State private var alreadyDownloaded = false
    //Variable's value justifies if journey was downloading after changing its name (if duplication occured).
    @State private var downloadChangedJourney = false
    //Variable's value contains data about journey's new name (after changing it because of duplication).
    @State private var journeyNewName = ""
    //Variable checks if presented journey was already downloaded (not to be mistaken with "areadyDownloaded which search for duplication in the Core Data).
    @State private var journeyIsDownloaded = false
    @State private var showSendingView = false
    @State private var showPhotoDetails = false
    @State private var showWeather = false
    @State private var expandWeather = false
    @State private var weatherLatitude = 0.0
    @State private var weatherLongitude = 0.0
    @State private var routeIsDisplayed = false
    @StateObject private var subscription = Subscription()
    @ObservedObject private var network = NetworkManager()
    @ObservedObject var notificationSetup = NotificationSetup()
    //Variable is meant to contain downloaded journeys.
    @FetchRequest(entity: Journey.entity(),
                  sortDescriptors: [],
                  predicate: nil,
                  animation: nil) var journeys: FetchedResults<Journey>
    
    //Journey owner's uid.
    var uid: String
    //Variable checks if program is showing downloaded (Core Data) journey or the journey from the server.
    var downloadMode: Bool
    var path: String

    var myJourney: Bool {
        self.uid == Auth.auth().currentUser?.uid
    }

    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .blue
    }
    
    var gold: Color {
        Color(uiColor: Colors.premiumColor)
    }
    
    var body: some View {
        
        VStack {


            if self.showPicture {
                HighlightedPhoto(highlightedPhotoIndex: self.$currentPhotoIndex,
                                 showPicture: self.$showPicture,
                                 highlightedPhoto: self.$highlightedPhoto,
                                 journey: self.journey)


            } else {

                VStack {
                    //Screen generated by the code below is very similar to the screen presented by SumUpView struct.
                    JourneyPickerView(choice: self.$viewMode, firstChoice: UIStrings.album, secondChoice: UIStrings.repeatTheJourney)
                        .onChange(of: viewMode, perform: { newValue in
                            if newValue == .threeDimensional {
                                self.currentLocationManager.mapView.deselectAnnotation(self.currentLocationManager.mapView.selectedAnnotations.first,
                                                                                       animated: true)
                                let annotationToSelect = self.currentLocationManager.mapView.annotations.first(where: {$0.title == String(self.currentPhotoIndex + 1)}) ??
                                self.currentLocationManager.mapView.userLocation
                                self.currentLocationManager.mapView.selectAnnotation(annotationToSelect, animated: true)
                            }
                        })
                        .padding(.horizontal, 5)

                    if self.viewMode == .photoAlbum {
                        VStack {
                            if !self.downloadedPhotos {
                                DownloadGalleryButton(journey: self.journey,
                                                      showDownloadAlert: self.$showDownloadAlert,
                                                      showPicture: self.$showPicture)
                            }

                            if self.journey.photos.map ({return $0.photo}).contains(UIImage()) {
                                Spacer()
                                ProgressView()
                                Spacer()
                            } else {
                                PhotosAlbumView(showPicture: self.$showPicture,
                                                photoIndex: self.$currentPhotoIndex,
                                                highlightedPhoto: self.$highlightedPhoto,
                                                layout: self.layout,
                                                singleJourney: self.journey)
                                .padding(.horizontal, 5)
                            }
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
                            Text(UIStrings.areYouSureToDownloadAllImages)
                        }
                    } else {
                        if self.journey.photosLocations.count < self.journey.numberOfPhotos {
                            VStack {
                                Spacer()
                                Text(UIStrings.unableToShowTheJourney)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                                Spacer()
                            }
                        } else {
                            ZStack {
                                MapView(walking: self.$walking,
                                        showPhoto: self.$showPicture,
                                        photoIndex: self.$currentPhotoIndex,
                                        showWeather: self.$showWeather,
                                        showDirections: self.$showWeather,
                                        expandWeather: self.$expandWeather,
                                        weatherLatitude: self.$weatherLatitude,
                                        weatherLongitude: self.$weatherLongitude,
                                        routeIsDisplayed: self.$routeIsDisplayed,
                                        photosLocations: self.journey.photosLocations)
                                .edgesIgnoringSafeArea(.all)
                                .environmentObject(self.currentLocationManager)

                                if self.showWeather {
                                    VStack {
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
                                                DirectionsView(location: self.journey.photosLocations[self.currentPhotoIndex])
                                            }
                                            Spacer()
                                        }
                                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                                        Spacer()
                                    }
                                }
                                if !self.showPicture {
                                    HStack {
                                        VStack (spacing: 10) {
                                            Spacer()
                                            if self.routeIsDisplayed {
                                                RemoveRouteView(routeIsDisplayed: self.$routeIsDisplayed, currentLocationManager: self.currentLocationManager)
                                            }
                                            if !self.journeys.map({$0.name}).contains(self.journey.name) {
                                                if !self.journeyIsDownloaded {
                                                    if self.journey.photos.map ({return $0.photo}).contains(UIImage()) {
                                                        ProgressView()
                                                            .padding(.vertical)
                                                    } else {
                                                        Button {
                                                            if self.subscription.subscriber {
                                                                DownloadManager(moc: self._moc, author: self.uid).downloadJourney(journey: self.journey)
                                                                print("ID: \(self.uid)")
                                                                self.journeyIsDownloaded = true
                                                                HapticFeedback.heavyHapticFeedback()
                                                            } else {
                                                                self.subscription.showPanel = true
                                                            }
                                                        } label: {
                                                            MapButton(imageName: Icons.arrowDownCircle)
                                                                .foregroundColor(self.subscription.subscriber ? self.buttonColor : self.gold)
                                                        }
                                                    }
                                                }
                                            } else {
                                                MapButton(imageName: Icons.checkmarkRectanglePortrait)
                                                    .disabled(true)
                                            }

                                            //Icons enabling users to choose between walking and driving directions.
                                            DirectionIcons(mapType: self.$currentLocationManager.mapView.mapType,
                                                           subscriber: self.$subscription.subscriber,
                                                           showPanel: self.$subscription.showPanel,
                                                           walking: self.$walking)

                                            //Buttons enabling users to re-center the map and change map's mode.
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
                                            JourneyControlView(numberOfPhotos: self.journey.photosLocations.count,
                                                               currentLocationManager: self.currentLocationManager,
                                                               currentPhotoIndex: self.$currentPhotoIndex,
                                                               mapType: self.$currentLocationManager.mapView.mapType)
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.top, 5)
                                    .padding(.bottom, 10)
                                }
                            }
                        }
                    }
                }

            }





















        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if self.showPicture {
                    if self.viewMode == .photoAlbum {
                        Menu {
                            Button {
                                self.showPicture = false
                                self.viewMode = .threeDimensional
                            } label: {
                                HStack {
                                    Text(UIStrings.viewInTheMap)
                                    Image(systemName: Icons.map)
                                }
                            }
                            Button {
                                self.showPhotoDetails = true
                            } label: {
                                HStack {
                                    Text(UIStrings.checkInfo)
                                    Image(systemName: Icons.infoCircle)
                                }
                            }
                        } label: {
                            Image(systemName: Icons.ellipsisCircle)
                        }
                    } else {
                        Button {
                            self.showPhotoDetails = true
                        } label: {
                            Image(systemName: Icons.infoCircle)
                        }
                    }
                } else {
                    if self.myJourney {
                        Menu {
                            Button {
                                self.showSendingView = true
                            } label: {
                                HStack {
                                    Text(UIStrings.sendJourneyInTheApp)
                                    Image(systemName: Icons.iphone)
                                }
                            }
                            Button {
                                CommunicationManager.sendPhotosViaSocialMedia(images: self.journey.photos.map{$0.photo})
                            } label: {
                                HStack {
                                    Text(UIStrings.sendPhotosViaSocialMedia)
                                    Image(systemName: Icons.squareAndArrowUp)
                                }
                            }
                        } label: {
                            Image(systemName: Icons.squareAndArrowUp)
                        }
                    } else {
                        Button {
                            CommunicationManager.sendPhotosViaSocialMedia(images: self.journey.photos.map{$0.photo})
                        } label: {
                            Image(systemName: Icons.squareAndArrowUp)
                        }
                    }
                }
            }
        }
        .task {
            Purchases.shared.getCustomerInfo { (customerInfo, error) in
                if customerInfo!.entitlements[Links.allFeaturesEntitlement]?.isActive == true {
                    self.subscription.subscriber = true
                }
            }
        }
        .onAppear {
            if self.journey.photosLocations.count == 0 {
                //Depending on journey mode, program will fetch data from different source.
                if !self.downloadMode {
                    self.getJourneyDetails()
                } else {
                    self.getDownloadedJourneyDetails()
                }
            }
        }
        .fullScreenCover(isPresented: self.$subscription.showPanel, content: {
            SubscriptionView(subscriber: self.$subscription.subscriber)
        })
        .sheet(isPresented: self.$showPhotoDetails, content: {
            PhotoDetailsView(photo: self.journey.photos[self.currentPhotoIndex])
        })
        .sheet(isPresented: self.$showSendingView, content: {
            SendViewedJourneyView(journey: self.journey)
        })
        .navigationBarTitle(self.journey.place, displayMode: .inline)
    }
    
    /**
     Function is responsible for pulling journey's data from the firebase database and storage.
     */
    func getJourneyDetails() {
        let fullPhotosPath = "\(self.path)/\(self.journey.name)/photos"
        Firestore.firestore().collection(fullPhotosPath).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.preparePhotosArray()
                querySnapshot!.documents.sorted(by: { $1["photoNumber"] as? Int ?? IntConstants.defaultValue > $0["photoNumber"] as? Int ?? IntConstants.defaultValue }).forEach { photo in
                    self.downloadPhotoDetails(queryDocumentSnapshot: photo)
                }
            }
        }
    }
    
    /**
     Function is responsible for pulling journey's data from the Core Data.
     */
    func getDownloadedJourneyDetails() {
        for journey in self.journeys {
            if journey.name == self.journey.name {
                self.journey.uid = Auth.auth().currentUser?.uid ?? ""
                self.journey.numberOfPhotos = journey.photosArray.count
                for index in 0...journey.photosArray.count - 1 {
                    let singlePhoto = SinglePhoto(number: index, photo: journey.photosArray[index].getImage)
                    self.journey.photos.append(singlePhoto)
                    self.journey.photosLocations.append(CLLocationCoordinate2D(latitude: journey.photosArray[index].latitude,
                                                                               longitude: journey.photosArray[index].longitude))
                }
                break
            }
        }
    }
    
    /**
     Function is responsible for filling photos array with null UIImage objects. Thanks to this users can view the journey before all images load. It usually takes less than a second but, this solution makes the application more intuitive and users can view locations before all photos load.
     */
    func preparePhotosArray() {
        if self.journey.numberOfPhotos != 0 {
            for _ in 0...self.journey.numberOfPhotos - 1 {
                self.journey.photos.append(SinglePhoto(number: 0, photo: UIImage()))
            }
        }
    }
    
    /**
     Function is responsible for sorting all journey's images due to their id.
     */
    func sortImages(dictionaryOfPhotos: [Int:UIImage]) -> [SinglePhoto] {
        var arrayOfImages: [SinglePhoto] = []
        
        for _ in 0...dictionaryOfPhotos.count - 1 {
            arrayOfImages.append(SinglePhoto(number: 0, photo: UIImage()))
        }
        
        dictionaryOfPhotos.forEach { photo in
            arrayOfImages[photo.key] = SinglePhoto(number: photo.key, photo: photo.value)
        }
        return arrayOfImages
    }
    
    /**
     Function is responsible for downloading for all photo's details from the database and storage.
     */
    func downloadPhotoDetails(queryDocumentSnapshot: QueryDocumentSnapshot) {
        self.journey.photosLocations.append(CLLocationCoordinate2D(latitude: queryDocumentSnapshot.get("latitude") as? CLLocationDegrees ?? CLLocationDegrees(),
                                                                   longitude: queryDocumentSnapshot.get("longitude") as? CLLocationDegrees ?? CLLocationDegrees()))
        
        //Image's reverence / url is used for downloading image from storage later on.
        let photoReference = Storage.storage().reference().child(queryDocumentSnapshot.get("photoUrl") as? String ?? "")
        
        //Image is downloaded from the storage.
        photoReference.downloadURL { url, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                //URLSESSIon uses url to download image.
                URLSession.shared.dataTask(with: url!) { data, response, error in
                    guard let data = data, let image = UIImage(data: data) else {
                        return
                    }
                    
                    //Image is appended to photos array on main thread so running application isn't interrupted.
                    DispatchQueue.main.async {
                        journey.photos[queryDocumentSnapshot.get("photoNumber") as? Int ?? IntConstants.defaultValue] =
                        (SinglePhoto(
                            date: (queryDocumentSnapshot.get("date") as? Timestamp)?.dateValue() ?? Date(),
                            number: queryDocumentSnapshot.get("photoNumber") as? Int ?? IntConstants.defaultValue,
                            photo: image,
                            coordinateLocation: CLLocationCoordinate2D(latitude: queryDocumentSnapshot.get("latitude") as? Double ?? 0,
                                                                       longitude: queryDocumentSnapshot.get("longitude") as? Double ?? 0),
                            location: queryDocumentSnapshot.get("location") as? String ?? "",
                            subLocation: queryDocumentSnapshot.get("subLocation") as? String ?? "",
                            administrativeArea: queryDocumentSnapshot.get("administrativeArea") as? String ?? "",
                            country: queryDocumentSnapshot.get("country") as? String ?? "",
                            isoCountryCode: queryDocumentSnapshot.get("isoCountryCode") as? String ?? "",
                            name: queryDocumentSnapshot.get("name") as? String ?? "",
                            postalCode: queryDocumentSnapshot.get("postalCode") as? String ?? "",
                            ocean: queryDocumentSnapshot.get("ocean") as? String ?? "",
                            inlandWater: queryDocumentSnapshot.get("inlandWater") as? String ?? "",
                            areasOfInterest: (queryDocumentSnapshot.get("areasOfInterest") as? String ?? "").components(separatedBy: ",")))
                    }
                }
                .resume()
            }
        }
    }

    /**
     Function is responsible for creating a new journey document in journeys collection in the firestore database. (Function also exists in SaveJourneyView).
     */
    func createJourney() {
        Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(Auth.auth().currentUser?.uid ?? "")/journeys").document(self.journey.name).setData([
            "name" : self.journey.name,
            "place" : self.journey.place,
            "uid" : Auth.auth().currentUser?.uid ?? "",
            "photosNumber" : self.journey.numberOfPhotos,
            "date" : Date(),
            "deletedJourney" : false
        ])
        for index in 0...self.journey.photosLocations.count - 1 {
            self.uploadPhoto(index: index)
        }
    }
    
    /**
     Function is responsible for uploading an image to the firebase storage and adding its details to firestore database. (Function also exists in SaveJourneyView).
     */
    func uploadPhoto(index: Int) {
        guard let photo = self.journey.photos.sorted(by: {$1.number > $0.number}).map({$0.photo})[index].jpegData(compressionQuality: 0.2) else {
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let photoReference = "\(Auth.auth().currentUser?.uid ?? "")/\(journey.name)/\(index)"
        let storageReference = Storage.storage().reference(withPath: photoReference)
        
        //Storage is populated with the image.
        storageReference.putData(photo, metadata: metaData) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            //Image's details are added to appropriate collection in firetore's database.
            Firestore.firestore().document("users/\(Auth.auth().currentUser?.uid ?? "")/friends/\(Auth.auth().currentUser?.uid ?? "")/journeys/\(self.journey.name)/photos/\(index)").setData([
                "latitude": self.journey.photosLocations[index].latitude,
                "longitude": self.journey.photosLocations[index].longitude,
                "photoUrl": photoReference,
                "photoNumber": index,
                "location": self.journey.photos[index].location,
                "subLocation": self.journey.photos[index].subLocation,
                "administrativeArea": self.journey.photos[index].administrativeArea,
                "country": self.journey.photos[index].country,
                "isoCountryCode": self.journey.photos[index].isoCountryCode,
                "name": self.journey.photos[index].name,
                "postalCode": self.journey.photos[index].postalCode,
                "ocean": self.journey.photos[index].ocean,
                "inlandWater": self.journey.photos[index].inlandWater,
                "areasOfInterest": self.journey.photos[index].areasOfInterest.joined(separator: ",")
            ])
        }
    }
}
