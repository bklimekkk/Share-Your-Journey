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
    @StateObject private var subscription = Subscription()
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var network = NetworkManager()
    
    //Similar variable described in SumUpView struct.
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    //Enum's cases control how users view journey's photos at the particular moment.
    enum ViewType {
        case photoAlbum
        case threeDimensional
    }
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
    @State private var savedToCameraRoll = false
    @State private var highlightedPhoto: UIImage = UIImage()
    @State private var downloadedPhotos = false
    @State private var showDownloadAlert = false
    //Variable controls if the journey can be found in user's downloaded journeys in the server.
    @State private var alreadyDownloaded = false
    //Variable's value justifies if users want to change journeys's name before downloading it (if journey's name duplicates.
    @State private var changeName = false
    //Variable's value justifies if journey was downloading after changing its name (if duplication occured).
    @State private var downloadChangedJourney = false
    //Variable's value contains data about journey's new name (after changing it because of duplication).
    @State private var journeyNewName = UIStrings.emptyString
    //Variable checks if presented journey was already downloaded (not to be mistaken with "areadyDownloaded which search for duplication in the Core Data).
    @State private var journeyIsDownloaded = false
    @State private var showSendingView = false
    @State private var showPhotoDetails = false
    @State private var showWeather = false
    @State private var expandWeather = false
    @State private var weatherLatitude = 0.0
    @State private var weatherLongitude = 0.0
    
    //Variable is responsible for saving data to Core Data.
    @Environment(\.managedObjectContext) var moc
    
    //Variable is meant to contain downloaded journeys.
    @FetchRequest(entity: Journey.entity(), sortDescriptors: [], predicate: nil, animation: nil) var journeys: FetchedResults<Journey>
    
    //Journey owner's email address.
    var email: String
    
    //Variable checks if program is showing downloaded (Core Data) journey or the journey from the server.
    var downloadMode: Bool
    var path: String

    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .accentColor
    }
    
    var gold: Color {
        Color(uiColor: Colors.premiumColor)
    }
    
    var body: some View {
        
        ZStack {
            VStack {
                
                //Screen generated by the code below is very similar to the screen presented by SumUpView struct.
                JourneyPickerView(choice: self.$viewMode, firstChoice: UIStrings.album, secondChoice: UIStrings.repeatTheJourney)
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
                                    expandWeather: self.$expandWeather,
                                    weatherLatitude: self.$weatherLatitude,
                                    weatherLongitude: self.$weatherLongitude,
                                    photos: self.journey.photos.sorted{$1.number > $0.number}.map{$0.photo},
                                    photosLocations: self.journey.photosLocations)
                            .edgesIgnoringSafeArea(.all)
                            .environmentObject(self.currentLocationManager)
                            .opacity(self.showPicture ? 0 : 1)
                            
                            if self.showWeather {
                                VStack {
                                    HStack {
                                        if self.expandWeather {
                                            WeatherView(latitude: self.weatherLatitude, longitude: self.weatherLongitude)
                                                .padding()
                                        } else {
                                            Button{
                                                withAnimation(.easeInOut(duration: 0.15)) {
                                                    self.expandWeather = true
                                                }
                                            }label: {
                                                MapButton(imageName: Icons.cloudSunFill)
                                                    .foregroundColor(self.colorScheme == .light ? .accentColor : .white)
                                                    .padding()
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .opacity(self.showPicture ? 0 : 1)
                            }
                            if !self.showPicture {
                                HStack {
                                    VStack {
                                        Spacer()
                                        if !self.downloadMode && !self.journeyIsDownloaded {
                                            if self.journey.photos.map ({return $0.photo}).contains(UIImage()) {
                                                ProgressView()
                                                    .padding(.vertical)
                                            } else {
                                                Button{
                                                    if self.subscription.subscriber {
                                                        if self.journeys.map({$0.name}).contains(self.journey.name) {
                                                            self.alreadyDownloaded = true
                                                            return
                                                        }
                                                        self.downloadJourney(name: self.journey.place)
                                                        withAnimation {
                                                            self.journeyIsDownloaded = true
                                                        }
                                                    } else {
                                                        self.subscription.showPanel = true
                                                    }
                                                } label: {
                                                    MapButton(imageName: Icons.squareAndArrowDown)
                                                        .foregroundColor(self.subscription.subscriber ? self.buttonColor : self.gold)
                                                }
                                            }
                                        } else if self.downloadMode && self.journey.networkProblem {
                                            Button{
                                                if self.network.connected {
                                                    self.createJourney()
                                                    for i in self.journeys {
                                                        if i.name == self.journey.name {
                                                            self.moc.delete(i)
                                                            try? self.moc.save()
                                                            break
                                                        }
                                                    }
                                                    withAnimation {
                                                        self.journey.networkProblem = false
                                                    }
                                                }
                                            } label: {
                                                MapButton(imageName: Icons.plus)
                                                    .foregroundColor(self.colorScheme == .light ? Color.accentColor : .white)
                                            }
                                        } else {
                                            MapButton(imageName: Icons.checkmark)
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
                                        JourneyControlView(journey: self.journey,
                                                           currentLocationManager: self.currentLocationManager,
                                                           currentPhotoIndex: self.$currentPhotoIndex)
                                    }
                                }
                                .padding()
                            }
                        }
                        .task {
                            self.currentPhotoIndex = 0
                        }
                    }
                }
            }
            HighlightedPhoto(savedToCameraRoll: self.$savedToCameraRoll,
                             highlightedPhotoIndex: self.$currentPhotoIndex,
                             showPicture: self.$showPicture,
                             highlightedPhoto: self.$highlightedPhoto,
                             subscriber: self.$subscription.subscriber,
                             showPanel: self.$subscription.showPanel,
                             journey: self.journey)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if self.showPicture {
                    Button{
                        self.showPhotoDetails = true
                    }label:{
                        Image(systemName: Icons.infoCircle)
                    }
                } else {
                    Menu {
                        Button(UIStrings.sendJourneyInTheApp) {
                            self.showSendingView = true
                        }
                        Button(UIStrings.sendPhotosViaSocialMedia) {
                            self.sendPhotosViaSocialMedia()
                        }
                    } label: {
                        Image(systemName: Icons.squareAndArrowUp)
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
        .alert(isPresented: self.$alreadyDownloaded) {
            
            //Alert is triggered if journey with the same name is already downloaded to Core Data.
            Alert(title: Text(UIStrings.journeyWithTheSameName),
                  message: Text(UIStrings.journeyWithTheSameNameAlreadyDownloaded),
                  primaryButton: .default(Text(UIStrings.ok)) {
                self.alreadyDownloaded = false
                self.changeName = true
            },
                  secondaryButton: .destructive(Text(UIStrings.cancel)) {
                self.alreadyDownloaded = false
            })
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
        .sheet(isPresented: self.$changeName, onDismiss: {
            
            //Sheet is presented to users if they choose to change duplicated journey's name.
            if self.downloadChangedJourney {
                self.downloadChangedJourney = false
                self.downloadJourney(name: journeyNewName)
                withAnimation {
                    self.journeyIsDownloaded = true
                }
                self.journeyNewName = UIStrings.emptyString
            }
        }, content: {
            DownloadChangesView(presentSheet: self.$changeName, download: self.$downloadChangedJourney, newName: self.$journeyNewName)
        })
        .navigationBarTitle(self.journey.place, displayMode: .inline)
    }
    
    /**
     Function is responsible for pulling journey's data from the firebase database and storage.
     */
    func getJourneyDetails() {
        let fullPhotosPath = "\(self.path)/\(self.journey.name)/photos"
        FirebaseSetup.firebaseInstance.db.collection(fullPhotosPath).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.preparePhotosArray()
                for i in querySnapshot!.documents.sorted(by: { $1["photoNumber"] as! Int > $0["photoNumber"] as! Int }) {
                    self.downloadPhotoDetails(queryDocumentSnapshot: i)
                }
            }
        }
    }
    
    /**
     Function is responsible for pulling journey's data from the Core Data.
     */
    func getDownloadedJourneyDetails() {
        for i in self.journeys {
            if i.name == self.journey.name {
                self.journey.email = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString
                self.journey.numberOfPhotos = i.photosArray.count
                for index in 0...i.photosArray.count - 1 {
                    let singlePhoto = SinglePhoto(number: index, photo: i.photosArray[index].getImage)
                    self.journey.photos.append(singlePhoto)
                    self.journey.photosLocations.append(CLLocationCoordinate2D(latitude: i.photosArray[index].latitude,
                                                                               longitude: i.photosArray[index].longitude))
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
        
        for i in dictionaryOfPhotos {
            arrayOfImages[i.key] = SinglePhoto(number: i.key, photo: i.value)
        }
        return arrayOfImages
    }
    
    /**
     Function is responsible for downloading for all photo's details from the database and storage.
     */
    func downloadPhotoDetails(queryDocumentSnapshot: QueryDocumentSnapshot) {
        self.journey.photosLocations.append(CLLocationCoordinate2D(latitude: queryDocumentSnapshot.get("latitude") as! CLLocationDegrees,
                                                                   longitude: queryDocumentSnapshot.get("longitude") as! CLLocationDegrees))
        
        //Image's reverence / url is used for downloading image from storage later on.
        let photoReference = FirebaseSetup.firebaseInstance.storage.reference().child(queryDocumentSnapshot.get("photoUrl") as! String)
        
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
                        journey.photos[queryDocumentSnapshot.get("photoNumber") as! Int] =
                        (SinglePhoto(
                            date: (queryDocumentSnapshot.get("date") as? Timestamp)?.dateValue() ?? Date(),
                            number: queryDocumentSnapshot.get("photoNumber") as! Int,
                            photo: image,
                            location: queryDocumentSnapshot.get("location") as! String,
                            subLocation: queryDocumentSnapshot.get("subLocation") as! String,
                            administrativeArea: queryDocumentSnapshot.get("administrativeArea") as! String,
                            country: queryDocumentSnapshot.get("country") as! String,
                            isoCountryCode: queryDocumentSnapshot.get("isoCountryCode") as! String,
                            name: queryDocumentSnapshot.get("name") as! String,
                            postalCode: queryDocumentSnapshot.get("postalCode") as! String,
                            ocean: queryDocumentSnapshot.get("ocean") as! String,
                            inlandWater: queryDocumentSnapshot.get("inlandWater") as! String,
                            areasOfInterest: (queryDocumentSnapshot.get("areasOfInterest") as! String).components(separatedBy: ",")))
                    }
                }
                .resume()
            }
        }
    }
    
    /**
     Function is responsible for saving the journey in Core Data.
     */
    func downloadJourney(name: String) {
        let newJourney = Journey(context: self.moc)
        newJourney.name = name
        newJourney.email = FirebaseSetup.firebaseInstance.auth.currentUser?.email
        newJourney.date = Date()
        newJourney.networkProblem = false
        newJourney.photosNumber = (self.journey.numberOfPhotos) as NSNumber
        var index = 0
        while index < self.journey.photos.count {
            let newImage = Photo(context: moc)
            newImage.id = Double(index + 1)
            newImage.journey = newJourney
            newImage.image = journey.photos[index].photo.jpegData(compressionQuality: 0.5)
            newImage.latitude = journey.photosLocations[index].latitude
            newImage.longitude = journey.photosLocations[index].longitude
            newImage.location = journey.photos[index].location
            newImage.subLocation = journey.photos[index].subLocation
            newImage.administrativeArea = journey.photos[index].administrativeArea
            newImage.country = journey.photos[index].country
            newImage.isoCountryCode = journey.photos[index].isoCountryCode
            newImage.name = journey.photos[index].name
            newImage.postalCode = journey.photos[index].postalCode
            newImage.ocean = journey.photos[index].ocean
            newImage.inlandWater = journey.photos[index].inlandWater
            newImage.areasOfInterest = journey.photos[index].areasOfInterest.joined(separator: ",")
            newJourney.addToPhotos(newImage)
            index+=1
        }
        
        //After all journey properties are set, changes need to be saved with context variable's function: save().
        try? self.moc.save()
    }
    
    /**
     Function is responsible for creating a new journey document in journeys collection in the firestore database. (Function also exists in SaveJourneyView).
     */
    func createJourney() {
        let instanceReference = FirebaseSetup.firebaseInstance
        instanceReference.db.collection("\(FirestorePaths.getFriends(email: instanceReference.auth.currentUser?.email ?? UIStrings.emptyString))/\(instanceReference.auth.currentUser?.email ?? UIStrings.emptyString)/journeys").document(self.journey.name).setData([
            "name" : self.journey.name,
            "place" : self.journey.place,
            "email" : FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString,
            "photosNumber" : self.journey.numberOfPhotos,
            "date" : Date(),
            "deletedJourney" : false
        ])
        for index in 0...self.journey.photosLocations.count - 1 {
            self.uploadPhoto(index: index, instanceReference: instanceReference)
        }
    }
    
    /**
     Function is responsible for uploading an image to the firebase storage and adding its details to firestore database. (Function also exists in SaveJourneyView).
     */
    func uploadPhoto(index: Int, instanceReference: FirebaseSetup) {
        guard let photo = self.journey.photos.sorted(by: {$1.number > $0.number}).map({$0.photo})[index].jpegData(compressionQuality: 0.2) else {
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let photoReference = "\(instanceReference.auth.currentUser?.email ?? "")/\(journey.name)/\(index)"
        let storageReference = instanceReference.storage.reference(withPath: photoReference)
        
        //Storage is populated with the image.
        storageReference.putData(photo, metadata: metaData) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            //Image's details are added to appropriate collection in firetore's database.
            instanceReference.db.document("users/\(instanceReference.auth.currentUser?.email ?? "")/friends/\(instanceReference.auth.currentUser?.email ?? "")/journeys/\(self.journey.name)/photos/\(index)").setData([
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

    func sendPhotosViaSocialMedia() {
        let activityViewController = UIActivityViewController(activityItems: self.journey.photos.map{$0.photo}, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController!.present(activityViewController, animated: true, completion: nil)
    }
}
