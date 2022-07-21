//
//  SendJourneyView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 17/02/2022.
//

import SwiftUI
import MapKit
import Firebase

//Struct responsible for providing users functionality necessary for sending journey to friend.
struct SendJourneyView: View {
    
    //Variable used for dismissing sheet that contains current struct.
    @Environment(\.presentationMode) var presentationMode
    
    //Email address of a friend to which user sends the journey.
    var targetEmail: String
    
    //Arrays contains journeys already sent to particular friend an these that haven't been sent yet.
    @State private var sentJourneys: [SingleJourney] = []
    @State private var unsentJourneys: [SingleJourney] = []
    
    var body: some View {
        VStack {
            
            List(unsentJourneys.sorted(by: {$0.date > $1.date}), id: \.self) { journey in
                HStack {
                    Text(journey.name)
                        .padding(.vertical, 30)
                    Spacer()
                    Button{
                        sendJourney(journey: journey)
                        
                        //After journey is sent, it needs to be deleted from list that gives user a choice of journeys to send.
                        withAnimation {
                            deleteFromSendingList(journeyName: journey.name)
                        }
                        
                    } label:{
                        Text("Send")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(Color.accentColor)
                }
                
            }
            .onAppear {
                prepareJourneysToSend()
            }
            
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                ButtonView(buttonTitle: "Done")
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }
    
    /**
     Function is responsible for sending entire journey to particular user.
     */
    func sendJourney(journey: SingleJourney) {
        
        //Journey is added to relevant collection in the firestore database (without photos references).
        FirebaseSetup.firebaseInstance.db.document("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(targetEmail)/journeys/\(journey.name)").setData([
            "name": journey.name,
            "email" : journey.email,
            "photosNumber" : journey.numberOfPhotos,
            "date" : Date(),
            "deletedJourney" : false
        ])
        
        let path = "users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "" )/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys/\(journey.name)/photos"
        
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                //All photos details are stored inside document representing particular journey.
                for i in querySnapshot!.documents.sorted(by: { $0["photoNumber"] as! Int > $1["photoNumber"] as! Int }) {
                    FirebaseSetup.firebaseInstance.db.document("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(targetEmail)/journeys/\(journey.name)/photos/\(i.documentID)").setData([
                        "latitude": i.get("latitude") as! CLLocationDegrees,
                        "longitude": i.get("longitude") as! CLLocationDegrees,
                        "photoUrl": i.get("photoUrl") as! String,
                        "photoNumber": i.get("photoNumber") as! Int
                    ])
                }
            }
        }
    }
    
    //Function is responsible for deleting particular journey from the list of unsent journeys.
    func deleteFromSendingList(journeyName: String) {
        for i in 0...unsentJourneys.count - 1 {
            if unsentJourneys[i].name == journeyName {
                unsentJourneys.remove(at: i)
                break
            }
        }
    }
    
    /**
     Function is responsible for preapring the list from which users can choose a journey to send.
     */
    func prepareJourneysToSend() {
        //First of all, all program fetches all user's journeys that were sent to particular friend from firebase database and stores them in first array.
        let ownEmail = FirebaseSetup.firebaseInstance.auth.currentUser?.email
        FirebaseSetup.firebaseInstance.db.collection("users/\(ownEmail ?? "")/friends/\(targetEmail)/journeys").getDocuments { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in snapshot!.documents {
                    if(i.documentID != "-") {
                        sentJourneys.append(SingleJourney(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "", name: i.documentID, date: (i.get("date") as? Timestamp)?.dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as! Int, photos: [], photosLocations: []))
                    }
                }
            }
            
            //Then program fetches all user's journeys and populates another array with journeys that can't be found in the previous array (containing journeys already send). In this way program knows which journeys haven't been sent yet and presents them to user.
            FirebaseSetup.firebaseInstance.db.collection("users/\(ownEmail ?? "")/friends/\(ownEmail ?? "")/journeys").getDocuments { (snapshot, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    for i in snapshot!.documents {
                        if !sentJourneys.map({$0.name}).contains(i.documentID) {
                            unsentJourneys.append(SingleJourney(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "", name: i.documentID, date: (i.get("date") as? Timestamp)?.dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as! Int, photos: [], photosLocations: []))
                        }
                    }
                }
            }
        }
    }
}
