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
    
    @State private var searchText = ""
    
    var filteredUnsentJourneys: [SingleJourney] {
        if searchText.isEmpty {
            return unsentJourneys
        } else {
            return unsentJourneys.filter{$0.name.contains(searchText)}
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchField(text: "Search your journeys", search: $searchText)
                    .padding(.top)
                VStack {
                    if filteredUnsentJourneys.isEmpty{
                        NoDataView(text: "No journeys to send. Tap to refresh.")
                    } else {
                        List(filteredUnsentJourneys.sorted(by: {$0.date > $1.date}), id: \.self) { journey in
                            HStack {
                                Text("\(journey.place), \(journey.date)")
                                    .padding(.vertical, 15)
                                Spacer()
                                Button{
                                    SendJourneyManager().sendJourney(journey: journey, targetEmail: targetEmail)
                                    
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
            .navigationTitle("Send journey to \(targetEmail)")
            .navigationBarTitleDisplayMode(.inline)
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
        //First of all, the program fetches all user's journeys that were sent to particular friend from firebase database and stores them in first array.
        let ownEmail = FirebaseSetup.firebaseInstance.auth.currentUser?.email
        FirebaseSetup.firebaseInstance.db.collection("users/\(ownEmail ?? "")/friends/\(targetEmail)/journeys").getDocuments { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in snapshot!.documents {
                    if(i.documentID != "-") {
                        sentJourneys.append(SingleJourney(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "", name: i.documentID, place: i.get("place") as! String, date: (i.get("date") as? Timestamp)?.dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as! Int, photos: [], photosLocations: []))
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
                            unsentJourneys.append(SingleJourney(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "", name: i.documentID, place: i.get("place") as! String, date: (i.get("date") as? Timestamp)?.dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as! Int, photos: [], photosLocations: []))
                        }
                    }
                }
            }
        }
    }
}
