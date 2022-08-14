//
//  SaveJourneyView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/03/2022.
//

import SwiftUI
import FirebaseStorage
import CoreData

struct SaveJourneyView: View {
    
    @FetchRequest(sortDescriptors: []) var downloadedJourneys: FetchedResults<Journey>
    @Environment(\.managedObjectContext) var moc
    
    //Variable is used to check if user's phone is connected to the internet.
    @ObservedObject var network = NetworkManager()
    
    //Variables were described in SumUpView struct.
    @Binding var presentSheet: Bool
    @Binding var done: Bool
    @Binding var journey: SingleJourney
    
    //Variable is supposed to hold data entered by user while naming the journey that they want to save.
    @State private var name = ""
    
    //Variables control if program should present user with error and what kind of message they should receive.
    @State private var errorBody = ""
    @State private var showErrorMessage = false
    
    //Variable is supposed to contain names of all user's journeys.
    @State private var journeys: [String] = []
    
    //Variables enable changing name of the duplicated journey that is about to be downloaded.
    @State private var alreadyDownloaded = false
    @State private var changeName = false
    @State private var downloadChangedJourney = false
    @State private var journeyIsDownloaded = false
    @State private var journeyNewName = ""
    
    //Variable decides if save button should be disabled.
    @State private var disableSaveButton = false
    
    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var body: some View {
        VStack {
            Text("Save journey")
            
            //Users are supposed to enter name of journey they are currently saving.
            TextField("Enter name", text: $name)

            Spacer()
            Button{
                
                //The input field can't be empty and can't contain '-' character.
                if trimmedName == "" || trimmedName.contains("-") {
                    errorBody = "Name of the journey needs to consist of at least one character and shouldn't contain '-' character"
                    showErrorMessage = true
                    return
                } else if journeys.contains(trimmedName) {
                    errorBody = "A journey with this name already exists in this account."
                    showErrorMessage = true
                    return
                } else if !network.connected {
                    errorBody = "Journey can't be saved because of lack of internet connection."
                    showErrorMessage = true
                    return
                }
                
                createJourney(journey: journey, name: trimmedName)
                journey.name = trimmedName
                done = true
                presentSheet = false
                
            } label: {
                ButtonView(buttonTitle: "Save")
            }
            .disabled(disableSaveButton)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .onAppear {
            populateJourneys()
        }
        .alert(isPresented: $alreadyDownloaded) {
            
            //Alert is triggered if journey with the same name is already downloaded to Core Data.
            Alert(title: Text("Journey with the same name"),
                  message: Text("Journey with the same name is already downloaded. Do you want to provide different name to this journey?"),
                  primaryButton: .default(Text("Ok")) {
                alreadyDownloaded = false
                changeName = true
            },
                  secondaryButton: .destructive(Text("Cancel")) {
                alreadyDownloaded = false
                disableSaveButton = false
            })
        }
        .sheet(isPresented: $changeName, onDismiss: {
            
            //Sheet is presented to users if they choose to change duplicated journey's name.
            if downloadChangedJourney {
                downloadChangedJourney = false
                downloadJourney(name: journeyNewName)
                done = true
                presentSheet = false
                withAnimation {
                    journeyIsDownloaded = true
                }
                journeyNewName = ""
            }
        }, content: {
            DownloadChangesView(presentSheet: $changeName, download: $downloadChangedJourney, newName: $journeyNewName)
        })
        
        .alert("Saving error", isPresented: $showErrorMessage) {
            Button("Ok", role: .cancel) {
                showErrorMessage = false
                errorBody = ""
            }
            if errorBody == "Journey can't be saved because of lack of internet connection." {
                Button("Download the journey") {
                    disableSaveButton = true
                    if !downloadedJourneys.map({$0.name}).contains(name) {
                        downloadJourney(name: name)
                        done = true
                        presentSheet = false
                    } else {
                        alreadyDownloaded = true
                    }
                }
            }
        } message: {
            Text(errorBody)
        }
        .padding()
    }
    
    /**
     Function is responsible for creating a new journey document in journeys collection in the firestore database.
     */
    func createJourney(journey: SingleJourney, name: String) {
        let instanceReference = FirebaseSetup.firebaseInstance
        instanceReference.db.collection("users/\(instanceReference.auth.currentUser?.email ?? "")/friends/\(instanceReference.auth.currentUser?.email ?? "")/journeys").document(name).setData([
            "name" : name,
            "email" : FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "",
            "photosNumber" : journey.numberOfPhotos,
            "date" : Date(),
            "deletedJourney" : false
        ])
        for index in 0...journey.photosLocations.count - 1 {
            uploadPhoto(journey: journey, name: name, index: index, instanceReference: instanceReference)
        }
    }
    
    /**
     Function is responsible for filling array with user's journeys.
     */
    func populateJourneys() {
        FirebaseSetup.firebaseInstance.db.collection("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys").getDocuments { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in snapshot!.documents {
                    if !(i.get("deletedJourney") as! Bool) {
                        journeys.append(i.documentID)
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for uploading an image to the firebase storage and adding its details to firestore database.
     */
    func uploadPhoto(journey: SingleJourney, name: String, index: Int, instanceReference: FirebaseSetup) {
        guard let photo = journey.photos.sorted(by: {$1.number > $0.number}).map({$0.photo})[index].jpegData(compressionQuality: 0.2) else {
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let photoReference = "\(instanceReference.auth.currentUser?.email ?? "")/\(name)/\(index)"
        let storageReference = instanceReference.storage.reference(withPath: photoReference)
        
        //Storage is populated with the image.
        storageReference.putData(photo, metadata: metaData) { metaData, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            //Image's details are added to appropriate collection in firetore's database.
            instanceReference.db.document("users/\(instanceReference.auth.currentUser?.email ?? "")/friends/\(instanceReference.auth.currentUser?.email ?? "")/journeys/\(name)/photos/\(index)").setData([
                "latitude": journey.photosLocations[index].latitude,
                "longitude": journey.photosLocations[index].longitude,
                "photoUrl": photoReference,
                "photoNumber": index
            ])
        }
    }
    /**
     Function is responsible for saving the journey in Core Data. (function also exists in SeeJourneyView struct).
     */
    func downloadJourney(name: String) {
        let newJourney = Journey(context: moc)
        
        newJourney.name = name
        newJourney.email = FirebaseSetup.firebaseInstance.auth.currentUser?.email
        newJourney.date = Date()
        newJourney.networkProblem = true
        newJourney.photosNumber = (journey.numberOfPhotos) as NSNumber
        var index = 0
        
        while index < journey.photos.count {
            let newImage = Photo(context: moc)
            newImage.id = Double(index + 1)
            newImage.journey = newJourney
            newImage.image = journey.photos[index].photo
            newImage.latitude = journey.photosLocations[index].latitude
            newImage.longitude = journey.photosLocations[index].longitude
            newJourney.addToPhotos(newImage)
            index+=1
        }
        
        //After all journey properties are set, changes need to be saved with context variable's function: save().
        try? moc.save()
    }
}
