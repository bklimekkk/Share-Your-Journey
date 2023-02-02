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
    
    //UID of a friend to which user sends the journey.
    var targetUID: String
    
    //Arrays contains journeys already sent to particular friend an these that haven't been sent yet.
    @State private var sentJourneys: [SingleJourney] = []
    @State private var unsentJourneys: [SingleJourney] = []
    @State private var searchText = UIStrings.emptyString
    @State private var loadedJourneysToSend = false

    var filteredUnsentJourneys: [SingleJourney] {
        if self.searchText.isEmpty {
            return self.unsentJourneys
        } else {
            return self.unsentJourneys.filter{$0.place.contains(self.searchText)}
        }
    }
    
    var body: some View {
        NavigationView {
            VStack (spacing: 0) {
                SearchField(text: UIStrings.searchYourJourneys, search: self.$searchText)
                    .padding(.top)
                VStack {
                    if !self.loadedJourneysToSend {
                        LoadingView()
                    } else if self.filteredUnsentJourneys.isEmpty {
                        NoDataView(text: UIStrings.noJourneysToSend)
                    } else {
                        List(self.filteredUnsentJourneys.sorted(by: {$0.date > $1.date}), id: \.self) { journey in
                            Button {
                                SendJourneyManager().sendJourney(journey: journey, targetUID: self.targetUID)

                                //After journey is sent, it needs to be deleted from list that gives user a choice of journeys to send.
                                withAnimation {
                                    self.deleteFromSendingList(journeyName: journey.name)
                                }
                            } label:{
                                HStack {
                                    Text(journey.place)
                                        .bold()
                                    Spacer()
                                    Text(DateManager.getDate(date: journey.date))
                                        .foregroundColor(Color.gray)
                                }
                                .padding(.vertical, 15)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(Color.primary)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .listStyle(.plain)
                    }
                }
                .onAppear {
                    self.prepareJourneysToSend(completion: {
                        self.loadedJourneysToSend = true
                    })
                }
                Divider()
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    ButtonView(buttonTitle: UIStrings.done)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .padding()
                }
            }
            .navigationTitle(UIStrings.selectJourneysToSend)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    //Function is responsible for deleting particular journey from the list of unsent journeys.
    func deleteFromSendingList(journeyName: String) {
        self.unsentJourneys.removeAll(where: {$0.name == journeyName})
    }
    
    /**
     Function is responsible for preapring the list from which users can choose a journey to send.
     */
    func prepareJourneysToSend(completion: @escaping () -> Void) {
        //First of all, the program fetches all user's journeys that were sent to particular friend from firebase database and stores them in first array.
        let ownUID = Auth.auth().currentUser?.uid
        Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: ownUID ?? UIStrings.emptyString))/\(self.targetUID)/journeys").getDocuments { (snapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for journey in snapshot!.documents {
                    self.sentJourneys.append(SingleJourney(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString,
                                                           name: journey.documentID,
                                                           place: journey.get("place") as? String ?? UIStrings.emptyString,
                                                           date: (journey.get("date") as? Timestamp)?.dateValue() ?? Date(),
                                                           numberOfPhotos: journey.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                }
            }
            
            //Then program fetches all user's journeys and populates another array with journeys that can't be found in the previous array (containing journeys already send). In this way program knows which journeys haven't been sent yet and presents them to user.
            Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: ownUID ?? UIStrings.emptyString))/\(ownUID ?? UIStrings.emptyString)/journeys").getDocuments { (snapshot, error) in
                completion()
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    for journey in snapshot!.documents {
                        if !self.sentJourneys.map({$0.name}).contains(journey.documentID) {
                            self.unsentJourneys.append(SingleJourney(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString,
                                                                     name: journey.documentID,
                                                                     place: journey.get("place") as? String ?? UIStrings.emptyString,
                                                                     date: (journey.get("date") as? Timestamp)?.dateValue() ?? Date(),
                                                                     numberOfPhotos: journey.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                        }
                    }
                }
            }
        }
    }
}
