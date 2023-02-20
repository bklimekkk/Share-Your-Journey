//
//  MultipleButtonsComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI
import MapKit

//Struct contains code responsible for generating icons allowing users to change the way how they receive directions to particular point (walking / driving).
struct DirectionIcons: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var mapType: MKMapType
    @Binding var subscriber: Bool
    @Binding var showPanel: Bool
    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .blue
    }
    var gold: Color {
        Color(uiColor: Colors.premiumColor)
    }
    @Binding var walking: Bool
    var body: some View {
        
        //Chosen icon is set to green colour.
        Button{
            if self.subscriber {
                self.walking = true
            } else {
                self.showPanel = true
            }
        } label : {
            if self.walking {
                MapButton(imageName: Icons.figureWalk)
                    .foregroundColor(Color.green)
            } else {
                 MapButton(imageName: Icons.figureWalk)
                    .foregroundColor(self.subscriber ? self.buttonColor : self.gold)
            }
        }
        
        Button {
            self.walking = false
        } label : {
            if self.walking {
                MapButton(imageName: Icons.car)
                    .foregroundColor(self.buttonColor)
            } else {
                MapButton(imageName: Icons.car)
                    .foregroundColor(Color.green)
            }
        }
    }
}

//Struct contains code that generate buttons necessary for saving the journey and closing sum-up screen.
struct SumUpFunctionalityButtonsView: View {
    @Environment(\.managedObjectContext) var moc
    //Variables are described in SumUpView struct.
    @Binding var journey: SingleJourney
    @Binding var showDeleteAlert: Bool
    @Binding var done: Bool
    var previousLocationManager: CurrentLocationManager
    var body: some View {
        HStack {
            Button {
                self.showDeleteAlert = true
            } label: {
                ButtonView(buttonTitle: UIStrings.quitButtonTitle)
                    .background(.red)
            }
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            
            Spacer()
            
            Button {
                HapticFeedback.heavyHapticFeedback()
                self.saveThePlace(index: self.journey.numberOfPhotos - 1)
                self.journey.name = UUID().uuidString
                DownloadManager(moc: self._moc, author: Auth.auth().currentUser?.uid ?? "").downloadJourney(journey: self.journey)
                self.createJourney(journey: self.journey)
                self.previousLocationManager.mapView.removeAnnotations(self.previousLocationManager.mapView.annotations)
                self.previousLocationManager.mapView.removeOverlays(self.previousLocationManager.mapView.overlays)
                self.done = true
            } label: {
                ButtonView(buttonTitle: UIStrings.saveJourneyButtonTitle)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 5)
    }

    func saveThePlace(index: Int) {
        // TODO: - save the place from the photo / reccur back by one index until 0 is reached.
        let location = self.journey.photos[index].location
        if location.isEmpty {
            if index == 0 {
                self.journey.place = UIStrings.undefined
                return
            } else {
                self.saveThePlace(index: index - 1)
            }
        } else {
            let subLocation = self.journey.photos[index].subLocation
            self.journey.place = subLocation.isEmpty || location == subLocation ? location : "\(location), \(subLocation)"
            return
        }
    }

    /**
     Function is responsible for creating a new journey document in journeys collection in the firestore database.
     */
    func createJourney(journey: SingleJourney) {
        Firestore.firestore().collection(FirestorePaths.myJourneys(uid: Auth.auth().currentUser?.uid ?? "")).document(journey.name).setData([
            "name" : journey.name,
            "place" : journey.place,
            "uid" : Auth.auth().currentUser?.uid ?? "",
            "photosNumber" : journey.numberOfPhotos,
            "date" : Date(),
            "deletedJourney" : false
        ])
        for index in 0...journey.photosLocations.count - 1 {
            self.uploadPhoto(journey: journey, name: journey.name, index: index)
        }
    }

    /**
     Function is responsible for uploading an image to the firebase storage and adding its details to firestore database.
     */
    func uploadPhoto(journey: SingleJourney, name: String, index: Int) {
        guard let photo = journey.photos.sorted(by: {$1.number > $0.number}).map({$0.photo})[index].jpegData(compressionQuality: 0.2) else {
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let photoReference = "\(Auth.auth().currentUser?.uid ?? "")/\(name)/\(index)"
        let storageReference = Storage.storage().reference(withPath: photoReference)
        //Storage is populated with the image.
        storageReference.putData(photo, metadata: metaData) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
            }
            //Image's details are added to appropriate collection in firetore's database.
            Firestore.firestore().document("\(FirestorePaths.myJourneys(uid: Auth.auth().currentUser?.uid ?? ""))/\(name)/photos/\(index)").setData([
                "latitude": journey.photosLocations[index].latitude,
                "longitude": journey.photosLocations[index].longitude,
                "photoUrl": photoReference,
                "photoNumber": index,
                "date": journey.photos[index].date,
                "location": journey.photos[index].location,
                "subLocation": journey.photos[index].subLocation,
                "administrativeArea": journey.photos[index].administrativeArea,
                "country": journey.photos[index].country,
                "isoCountryCode": journey.photos[index].isoCountryCode,
                "name": journey.photos[index].name,
                "postalCode": journey.photos[index].postalCode,
                "ocean": journey.photos[index].ocean,
                "inlandWater": journey.photos[index].inlandWater,
                "areasOfInterest": journey.photos[index].areasOfInterest.joined(separator: ",")
            ])
        }
    }
}
