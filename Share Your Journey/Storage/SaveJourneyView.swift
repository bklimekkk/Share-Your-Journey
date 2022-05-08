//
//  SaveJourneyView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/03/2022.
//

import SwiftUI
import FirebaseStorage

struct SaveJourneyView: View {
    
    //Variable is used to check if user's phone is connected to the internet.
    @ObservedObject var network = NetworkManager()
    
    //Variables were described in SumUpView struct.
    @Binding var presentSheet: Bool
    @Binding var done: Bool
    var journey: SingleJourney
    
    //Variable is supposed to hold data entered by user while naming the journey that they want to save.
    @State private var name = ""
    
    //Variables control if program should present user with error and what kind of message they should receive.
    @State private var errorBody = ""
    @State private var showErrorMessage = false
    
    //Variable is supposed to contain names of all user's journeys.
    @State private var journeys: [String] = []
    
    var body: some View {
        VStack {
            Text("Save journey")
                .font(.system(size:30))
            
            Spacer()
            
            //Users are supposed to enter name of journey they are currently saving.
            TextField("Enter name", text: $name)
                .font(.system(size: 50))
            Spacer()
            Button{
                
                //Operation is possible only with internet connection, so this if statement checks it.
                if network.connected {
                    
                    //The input field can't be empty and can't contain '-' character.
                    if name == "" || name.contains("-") {
                        errorBody = "Name of the journey needs to consist of at least one character and shouldn't contain '-' character"
                        showErrorMessage = true
                        return
                    } else if journeys.contains(name) {
                        errorBody = "A journey with this name already exists in this account."
                        showErrorMessage = true
                        return
                    }
                    
                    createJourney()
                    done = true
                    presentSheet = false
                } else {
                    errorBody = "Journey can't be saved because of lack of internet connection."
                    showErrorMessage = true
                }
               
            } label: {
                ButtonView(buttonTitle: "Save")
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .onAppear {
            populateJourneys()
        }
        .alert(errorBody, isPresented: $showErrorMessage) {
            Button("OK", role: .cancel) {
                showErrorMessage = false
                errorBody = ""
            }
        }
        .padding()
    }
    
    /**
     Function is responsible for creating a new journey document in journeys collection in the firestore database.
     */
    func createJourney() {
        let instanceReference = FirebaseSetup.firebaseInstance
        instanceReference.db.collection("users/\(instanceReference.auth.currentUser?.email ?? "")/friends/\(instanceReference.auth.currentUser?.email ?? "")/journeys").document(name).setData([
            "name" : name,
            "email" : FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "",
            "photosNumber" : journey.numberOfPhotos,
            "date" : Date()
        ])
        for index in 0...journey.photosLocations.count - 1 {
            uploadPhoto(index: index, instanceReference: instanceReference)
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
                    journeys.append(i.documentID)
                }
            }
        }
    }
    
    /**
     Function is responsible for uploading an image to the firebase storage and adding its details to firestore database.
     */
    func uploadPhoto(index: Int, instanceReference: FirebaseSetup) {
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
    
}
