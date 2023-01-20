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
    @State private var journeyToDelete = UIStrings.emptyString
    //Variable's value controls if program should delete journey from storage or not.
    @State private var deleteFromStorage = true
    @State private var loadedYourJourneys = false
    //Friend's email address.
    var email: String
    var sentByYouFiltered: [SingleJourney]

    var sentByYouFilteredSorted: [SingleJourney] {
        return self.sentByYouFiltered.sorted(by: {$0.date > $1.date})
    }

    var body: some View {
        
        VStack {
            if !self.loadedYourJourneys {
                LoadingView()
            } else if self.sentByYouFiltered.isEmpty {
                NoDataView(text: UIStrings.noJourneysToShow)
                    .onTapGesture {
                        self.loadedYourJourneys = false
                        self.populateYourJourneys(completionHandler: {
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
                                    .padding(.vertical, 15)

                                Spacer()

                                Text(DateManager().getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }
                            NavigationLink(destination: SeeJourneyView(journey: journey, email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString, downloadMode: false, path: "\(FirestorePaths.getFriends(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString))/\(self.email)/journeys")) {
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
                    self.populateYourJourneys(completionHandler: {
                        self.loadedYourJourneys = true
                    })
                }
                //Alert is shown if users want to delete any journey they sent.
                .alert(isPresented: self.$askAboutDeletion) {
                    Alert (title: Text(UIStrings.deleteJourney),
                           message: Text(UIStrings.sureToDelete),
                           primaryButton: .cancel(Text(UIStrings.cancel)) {
                        self.askAboutDeletion = false
                        self.journeyToDelete = UIStrings.emptyString
                    },
                           secondaryButton: .destructive(Text(UIStrings.delete)) {
                        
                        self.deleteJourneyFromDatabase()
                        
                        //If journey doesn't exist in any other place in the server, it is completely deleted from storage.
                        for i in 0...sentByYou.count - 1 {
                            if self.sentByYou[i].name == self.journeyToDelete {
                                if self.deleteFromStorage {
                                    self.deleteJourneyFromStorage(numberOfPhotos: sentByYou[i].numberOfPhotos - 1)
                                }
                                self.sentByYou.remove(at: i)
                                break
                            }
                        }
                        self.deleteFromStorage = true
                        self.askAboutDeletion = false
                        self.journeyToDelete = UIStrings.emptyString
                    }
                    )
                }
            }
        }
        .fullScreenCover(isPresented: self.$sendJourneyScreen, onDismiss: {
            self.populateYourJourneys(completionHandler: {
                self.loadedYourJourneys = true
            })
        }) {
            SendJourneyView(targetEmail: self.email)
        }
        .onAppear {
            self.populateYourJourneys(completionHandler: {
                self.loadedYourJourneys = true
            })
        }
    }
    
    /**
     Function is responsible for populating array with users' journeys with data from the server.
     */
    func populateYourJourneys(completionHandler: @escaping() -> Void) {
        let path = "\(FirestorePaths.getFriends(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString))/\(email)/journeys"
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    completionHandler()
                    //If conditions are met, journey's data is appended to the array.
                    if !self.sentByYou.map({return $0.name}).contains(i.documentID) && i.documentID != "-" && !(i.get("deletedJourney") as? Bool ?? false) {
                        self.sentByYou.append(SingleJourney(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString,
                                                            name: i.documentID,
                                                            place: i.get("place") as? String ?? UIStrings.emptyString,
                                                            date: (i.get("date") as? Timestamp)?.dateValue() ?? Date(),
                                                            numberOfPhotos: i.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for searching entire database (appropriate collections) in order to find out if journey's data still exist somewhere in the server.
     */
    func searchJourneyInDatabase(journey: SingleJourney) {
        let friendsPath = FirestorePaths.getFriends(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)
        FirebaseSetup.firebaseInstance.db.collection(friendsPath).getDocuments { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                //Firstly, algorithm searches for all user's friends, then it checks all journeys sent to them by this user.
                for i in snapshot!.documents {
                    if i.documentID != self.email {
                        FirebaseSetup.firebaseInstance.db.collection("\(friendsPath)/\(i.documentID)/journeys").getDocuments { journeySnapshot, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                for j in journeySnapshot!.documents {
                                    if j.documentID == journey.name {
                                        self.deleteFromStorage = false
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        self.askAboutDeletion = true
        self.journeyToDelete = journey.name
    }
    
    /**
     Function is responsible for deleting journey from list of journeys sent by user to particular friend.
     */
    func deleteJourneyFromDatabase() {
        let yourEmail = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString
        let path = "\(FirestorePaths.getFriends(email: yourEmail))/\(email)/journeys"
        
        //Before collection is deleted, program needs to delete its all photos references (Collection needs to be empty in order to be deleted eternally).
        FirebaseSetup.firebaseInstance.db.collection("\(path)/\(journeyToDelete)/photos").getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    i.reference.delete()
                }
            }
        }
        
        FirebaseSetup.firebaseInstance.db.collection(path).document(journeyToDelete).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    /**
     Function is responsible for deleting journey's photos from storage.
     */
    func deleteJourneyFromStorage(numberOfPhotos: Int) {
        
        //Each photo is deleted separately.
        for j in 0...numberOfPhotos {
            let deleteReference = FirebaseSetup.firebaseInstance.storage.reference().child("\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)/\(journeyToDelete)/\(j)")
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
        self.searchJourneyInDatabase(journey: self.sentByYouFilteredSorted[offsets[offsets.startIndex]])
    }
}
