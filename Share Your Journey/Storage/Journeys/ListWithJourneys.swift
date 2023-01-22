//
//  ListWithJourneys.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
import Firebase

//Struct contains code responsible for displaying list of user's journeys.
struct ListWithJourneys: View {

    var journeysFilteredList: [SingleJourney]

    //Variables are described in JourneysView struct.
    @Binding var journeysList: [SingleJourney]
    @Binding var journeyToDelete: String
    @Binding var deleteFromStorage: Bool
    @Binding var askAboutDeletion: Bool
    @State private var loadedJourneys = false
    var sortedJourneysFilteredList: [SingleJourney] {
        return self.journeysFilteredList.sorted(by: {$0.date > $1.date})
    }
    var body: some View {
        VStack {
            if !self.loadedJourneys {
                LoadingView()
            } else if self.journeysFilteredList.isEmpty {
                NoDataView(text: UIStrings.noJourneysToShowTapToRefresh)
                    .onTapGesture {
                        self.clearInvalidJourneys()
                        self.loadedJourneys = false
                        self.updateJourneys(completion: {
                            self.loadedJourneys = true
                        })
                    }
            } else {
                List {
                    ForEach (self.sortedJourneysFilteredList, id: \.self) { journey in
                        ZStack {
                            HStack {
                                Text(journey.place)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 15)
                                Spacer()
                                Text(DateManager.getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }

                            NavigationLink (destination: SeeJourneyView(journey: journey, uid: FirebaseSetup.firebaseInstance.auth.currentUser?.uid ?? UIStrings.emptyString, downloadMode: false, path: "\(FirestorePaths.getFriends(uid: FirebaseSetup.firebaseInstance.auth.currentUser?.uid ?? UIStrings.emptyString))/\(FirebaseSetup.firebaseInstance.auth.currentUser?.uid ?? UIStrings.emptyString)/journeys")) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                    }
                    .onDelete(perform: self.delete)
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.plain)
                .alert(isPresented: self.$askAboutDeletion) {
                    Alert (title: Text(UIStrings.deleteJourney),
                           message: Text(UIStrings.sureToDelete),
                           primaryButton: .cancel(Text(UIStrings.cancel)) {
                        self.askAboutDeletion = false
                        self.journeyToDelete = UIStrings.emptyString
                    },
                           secondaryButton: .destructive(Text(UIStrings.delete)) {
                        let uid = FirebaseSetup.firebaseInstance.auth.currentUser?.uid ?? UIStrings.emptyString
                        let path = "\(FirestorePaths.getFriends(uid: uid))/\(uid)/journeys"
                        //Photos need to be leted from both database and storage, if needed.
                        self.deleteAllPhotos(path: path)
                        self.deleteJourneyFromServer(path: path)
                        self.deleteJourneyFromStorage()
                        self.deleteFromStorage = true
                        self.askAboutDeletion = false
                        self.journeyToDelete = UIStrings.emptyString
                    }
                    )
                }
            }
        }
        .onAppear {
            //List is updated every time the screen appears.
            self.clearInvalidJourneys()
            self.updateJourneys(completion: {
                self.loadedJourneys = true
            })
        }
        .refreshable {
            self.clearInvalidJourneys()
            self.updateJourneys(completion: {
                self.loadedJourneys = true
            })
        }
    }
    
    /**
     Function is responsible for deleting all images' references from firestore database.
     */
    func deleteAllPhotos(path: String) {
        FirebaseSetup.firebaseInstance.db.collection("\(path)/\(journeyToDelete)/photos").getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    i.reference.delete()
                }
            }
        }
    }
    
    /**
     Function is responsible for deleting journey collection from firestore database.
     */
    func deleteJourneyFromServer(path: String) {
        FirebaseSetup.firebaseInstance.db.collection(path).document(self.journeyToDelete).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(UIStrings.journeyDeletedSuccesfully)
            }
        }
    }
    
    /**
     Function is responsible for deleting entire journey directory from storage, if needed.
     */
    func deleteJourneyFromStorage() {
        for i in 0...self.journeysList.count - 1 {
            if self.journeysList[i].name == self.journeyToDelete {
                if self.deleteFromStorage {
                    for j in 0...self.journeysList[i].numberOfPhotos - 1 {
                        let deleteReference = FirebaseSetup.firebaseInstance.storage.reference().child("\(FirebaseSetup.firebaseInstance.auth.currentUser?.uid ?? UIStrings.emptyString)/\(self.journeyToDelete)/\(j)")
                        deleteReference.delete { error in
                            if error != nil {
                                print("Error while deleting journey from storage")
                            } else {
                                print("Journey deleted from storage successfully")
                            }
                        }
                    }
                }
                self.journeysList.remove(at: i)
                break
            }
        }
    }
    
    /**
     Function is responsible for clearing array containing journeys, if user has changed.
     */
    func clearInvalidJourneys() {
        if self.journeysList.count != 0 && self.journeysList[0].uid != FirebaseSetup.firebaseInstance.auth.currentUser?.uid {
            self.journeysList = []
        }
    }
    
    /**
     Function is responsible for adding journeys to array, and refreshing it if needed.
     */
    func updateJourneys(completion: @escaping () -> Void) {
        let uid = FirebaseSetup.firebaseInstance.auth.currentUser?.uid ?? UIStrings.emptyString
        let path = "\(FirestorePaths.getFriends(uid: uid))/\(uid)/journeys"
        
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if !self.journeysList.map({return $0.name}).contains(i.documentID) && i.documentID != "-" && !(i.get("deletedJourney") as? Bool ?? false) {
                        self.journeysList.append(SingleJourney(uid: i.get("uid") as? String ?? UIStrings.emptyString, name: i.documentID, place: i.get("place") as? String ?? UIStrings.emptyString, date: (i.get("date") as? Timestamp)?
                            .dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for checking if journey occurs anywhere else in the database. If it doesn't, journey is ready to be deleted from storage as well.
     */
    func checkBeforeDeletion(journey: SingleJourney) {
        let friendsPath = FirestorePaths.getFriends(uid: FirebaseSetup.firebaseInstance.auth.currentUser?.uid ?? UIStrings.emptyString)
        
        FirebaseSetup.firebaseInstance.db.collection(friendsPath).getDocuments { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in snapshot!.documents {
                    if i.documentID != FirebaseSetup.firebaseInstance.auth.currentUser?.uid {
                        FirebaseSetup.firebaseInstance.db.collection("\(friendsPath)/\(i.documentID)/journeys").getDocuments {
                            journeySnapshot, error in
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

    func delete(at offsets: IndexSet) {
        self.checkBeforeDeletion(journey: self.sortedJourneysFilteredList[offsets[offsets.startIndex]])
    }
}
