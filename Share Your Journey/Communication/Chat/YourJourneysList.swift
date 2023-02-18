//
//  YourJourneysList.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
import Firebase

//Struct contains code responsible for generating list with user's journeys in a chat with friend.
struct YourJourneysList: View {
    
    //Variables described in ChatView struct.
    @Binding var searchJourney: String
    @Binding var sendJourneyScreen: Bool
    @Binding var askAboutDeletion: Bool
    @Binding var sentByYou: [SingleJourney]
    
    //Variable is supposed to contain name of the journey that currently is supposed to be deleted.
    @State private var journeyToDelete = SingleJourney()
    @State private var loadedYourJourneys = false
    //Friend's uid.
    var uid: String

    var sentByYouFilteredSorted: [SingleJourney] {
        if self.searchJourney == "" {
            return self.sentByYou
                .sorted(by: {$0.operationDate > $1.operationDate})
        } else {
            return self.sentByYou
                .filter({return $0.place.lowercased().contains(self.searchJourney.lowercased())})
                .sorted(by: {$0.operationDate > $1.operationDate})
        }
    }

    var body: some View {
        
        VStack {
            if !self.loadedYourJourneys {
                LoadingView()
            } else if self.sentByYouFilteredSorted.isEmpty {
                NoDataView(text: UIStrings.noJourneysToShowTapToRefresh)
                    .onTapGesture {
                        self.loadedYourJourneys = false
                        self.populateYourJourneys(completion: {
                            self.loadedYourJourneys = true
                        })
                    }
            } else {
                //List is sorted by date.
                List {
                    ForEach (self.sentByYouFilteredSorted, id: \.self) { journey in
                        ZStack {
                            HStack {
                                Text(journey.place)
                                    .bold()
                                    .padding(.vertical, 15)
                                Spacer()
                                Text(DateManager.getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }
                            NavigationLink(destination: SeeJourneyView(journey: journey,
                                                                       uid: Auth.auth().currentUser?.uid ?? "",
                                                                       downloadMode: false,
                                                                       path: "\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(self.uid)/journeys")) {
                                EmptyView()
                            }
                                                                       .opacity(0)
                        }
                    }
                    .onDelete(perform: self.delete)
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.inset)
                .refreshable {
                    self.populateYourJourneys(completion: {
                        self.loadedYourJourneys = true
                    })
                }
                //Alert is shown if users want to delete any journey they sent.
                .alert(isPresented: self.$askAboutDeletion) {
                    Alert (title: Text(UIStrings.deleteJourney),
                           message: Text(UIStrings.sureToDelete),
                           primaryButton: .cancel(Text(UIStrings.cancel)) {
                        self.askAboutDeletion = false
                        self.journeyToDelete = SingleJourney()
                    },
                           secondaryButton: .destructive(Text(UIStrings.delete)) {
                        self.deleteJourneyFromDatabase(name: self.journeyToDelete.name)
                        // TODO: - check for a completion
                        self.checkForDuplicate(name: self.journeyToDelete.name) { lastCopy in
                            if lastCopy {
                                self.deleteJourneyFromStorage(journey: self.journeyToDelete)
                            }
                            self.sentByYou.removeAll(where: {$0.name == self.journeyToDelete.name})
                            self.journeyToDelete = SingleJourney()
                        }
                    }
                    )
                }
            }
        }
        .fullScreenCover(isPresented: self.$sendJourneyScreen, onDismiss: {
            self.populateYourJourneys(completion: {
                self.loadedYourJourneys = true
            })
        }) {
            SendJourneyView(targetUID: self.uid)
        }
        .onAppear {
            self.sentByYou = []
            self.populateYourJourneys(completion: {
                self.loadedYourJourneys = true
            })
        }
    }
    
    /**
     Function is responsible for populating array with users' journeys with data from the server.
     */
    func populateYourJourneys(completion: @escaping() -> Void) {
        let path = "\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(self.uid)/journeys"
        Firestore.firestore().collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for journey in querySnapshot!.documents {
                    //If conditions are met, journey's data is appended to the array.
                    if !self.sentByYou.map({return $0.name}).contains(journey.documentID) && !(journey.get("deletedJourney") as? Bool ?? false) {
                        self.sentByYou.append(SingleJourney(uid: Auth.auth().currentUser?.uid ?? "",
                                                            name: journey.documentID,
                                                            place: journey.get("place") as? String ?? "",
                                                            date: (journey.get("date") as? Timestamp)?.dateValue() ?? Date.now,
                                                            operationDate: (journey.get("operationDate") as? Timestamp)?.dateValue() ?? Date.now,
                                                            numberOfPhotos: journey.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for searching entire database (appropriate collections) in order to find out if journey's data still exist somewhere in the server.
     */
    func checkForDuplicate(name: String, completion: @escaping(Bool) -> Void) {
        let friendsPath = FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? "")
        Firestore.firestore().collection(friendsPath).getDocuments { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let documents = snapshot!.documents.filter({$0.documentID != self.uid})
                if documents.isEmpty {
                    completion(true)
                } else {
                    for friend in documents {
                        Firestore.firestore().collection("\(friendsPath)/\(friend.documentID)/journeys").getDocuments { journeysSnapshot, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                if journeysSnapshot!.documents.first(where: {$0.documentID == name}) != nil {
                                    completion(false)
                                } else {
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for deleting journey from list of journeys sent by user to particular friend.
     */
    func deleteJourneyFromDatabase(name: String) {
        let yourUID = Auth.auth().currentUser?.uid ?? ""
        let path = "\(FirestorePaths.getFriends(uid: yourUID))/\(self.uid)/journeys"
        
        //Before collection is deleted, program needs to delete its all photos references (Collection needs to be empty in order to be deleted eternally).
        Firestore.firestore().collection("\(path)/\(name)/photos").getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                querySnapshot!.documents.forEach { document in
                    document.reference.delete()
                }
            }
        }
        Firestore.firestore().collection(path).document(name).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    /**
     Function is responsible for deleting journey's photos from storage.
     */
    func deleteJourneyFromStorage(journey: SingleJourney) {
        
        //Each photo is deleted separately.
        for photoNumber in 0...journey.numberOfPhotos {
            let deleteReference = Storage.storage().reference().child("\(Auth.auth().currentUser?.uid ?? "")/\(journey.name)/\(photoNumber)")
            deleteReference.delete { error in
                if error != nil {
                    print("Error while deleting journey from storage")
                } else {
                    print("Journey deleted from storage successfully")
                }
            }
        }
    }

    func delete(at offsets: IndexSet) {
        self.journeyToDelete = self.sentByYouFilteredSorted[offsets[offsets.startIndex]]
        self.askAboutDeletion = true
    }
}
