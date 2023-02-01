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
    @Binding var journeyToDelete: SingleJourney
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
                                    .bold()
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 15)
                                Spacer()
                                Text(DateManager.getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }

                            NavigationLink (destination: SeeJourneyView(journey: journey, uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString, downloadMode: false, path: "\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString))/\(Auth.auth().currentUser?.uid ?? UIStrings.emptyString)/journeys")) {
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
                        self.journeyToDelete = SingleJourney()
                    },
                           secondaryButton: .destructive(Text(UIStrings.delete)) {
                        //Photos need to be leted from both database and storage, if needed.
                        self.deleteJourneyFromServer(name: self.journeyToDelete.name)
                        self.checkForDuplicate(name: self.journeyToDelete.name) { lastCopy in
                            if lastCopy {
                                self.deleteJourneyFromStorage(journey: self.journeyToDelete)
                            }
                            self.journeysList.removeAll(where: {$0.name == self.journeyToDelete.name})
                            self.journeyToDelete = SingleJourney()
                        }
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
     Function is responsible for deleting journey collection from firestore database.
     */
    func deleteJourneyFromServer(name: String) {
        let yourUID = Auth.auth().currentUser?.uid ?? UIStrings.emptyString
        let path = "\(FirestorePaths.getFriends(uid: yourUID))/\(yourUID)/journeys"
        Firestore.firestore().collection("\(path)/\(name)/photos").getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    i.reference.delete()
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
     Function is responsible for deleting entire journey directory from storage, if needed.
     */
    func deleteJourneyFromStorage(journey: SingleJourney) {
        for i in 0...journey.numberOfPhotos {
            let deleteReference = Storage.storage().reference().child("\(Auth.auth().currentUser?.uid ?? UIStrings.emptyString)/\(journey.name)/\(i)")
            deleteReference.delete { error in
                if error != nil {
                    print("Error while deleting journey from storage")
                } else {
                    print("Journey deleted from storage successfully")
                }
            }
        }
    }
    
    /**
     Function is responsible for clearing array containing journeys, if user has changed.
     */
    func clearInvalidJourneys() {
        if self.journeysList.count != 0 && self.journeysList[0].uid != Auth.auth().currentUser?.uid {
            self.journeysList = []
        }
    }
    
    /**
     Function is responsible for adding journeys to array, and refreshing it if needed.
     */
    func updateJourneys(completion: @escaping () -> Void) {
        let uid = Auth.auth().currentUser?.uid ?? UIStrings.emptyString
        let path = "\(FirestorePaths.getFriends(uid: uid))/\(uid)/journeys"
        
        Firestore.firestore().collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if !self.journeysList.map({return $0.name}).contains(i.documentID) && !(i.get("deletedJourney") as? Bool ?? false) {
                        self.journeysList.append(SingleJourney(uid: i.get("uid") as? String ?? UIStrings.emptyString,
                                                               name: i.documentID, place: i.get("place") as? String ?? UIStrings.emptyString,
                                                               date: (i.get("date") as? Timestamp)?
                            .dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for checking if journey occurs anywhere else in the database. If it doesn't, journey is ready to be deleted from storage as well.
     */
    func checkForDuplicate(name: String, completion: @escaping(Bool) -> Void) {
        let friendsPath = FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString)
        Firestore.firestore().collection(friendsPath).getDocuments { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let documents = snapshot!.documents.filter({$0.documentID != Auth.auth().currentUser?.uid})
                if documents.isEmpty {
                    completion(true)
                } else {
                    for friend in documents {
                        Firestore.firestore().collection("\(friendsPath)/\(friend.documentID)/journeys").getDocuments { journeysSnapshot, error in
                            if error != nil {
                                print("there's a severe error")
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

    func delete(at offsets: IndexSet) {
        self.journeyToDelete = self.sortedJourneysFilteredList[offsets[offsets.startIndex]]
        self.askAboutDeletion = true
    }
}
