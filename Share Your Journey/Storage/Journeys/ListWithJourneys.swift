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

    var sortedJourneysFilteredList: [SingleJourney] {
        return self.journeysFilteredList.sorted(by: {$0.date > $1.date})
    }
    var body: some View {
        VStack {
            if self.journeysFilteredList.isEmpty {
                NoDataView(text: "No journeys to show. Tap to refresh.")
                    .onTapGesture {
                        self.clearInvalidJourneys()
                        self.updateJourneys()
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
                                Text(DateManager().getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }

                            NavigationLink (destination: SeeJourneyView(journey: journey, email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "", downloadMode: false, path: "users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys")) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                    }
                    .onDelete(perform: self.delete)
                }
                .listStyle(.plain)
                .alert(isPresented: self.$askAboutDeletion) {
                    Alert (title: Text("Delete journey"),
                           message: Text("Are you sure that you want to delete this journey?"),
                           primaryButton: .cancel(Text("Cancel")) {
                        self.askAboutDeletion = false
                        self.journeyToDelete = ""
                    },
                           secondaryButton: .destructive(Text("Delete")) {
                        
                        let email = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? ""
                        let path = "users/\(email)/friends/\(email)/journeys"
                        
                        //Photos need to be leted from both database and storage, if needed.
                        
                        self.deleteAllPhotos(path: path)
                        self.deleteJourneyFromServer(path: path)
                        self.deleteJourneyFromStorage()
                        
                        self.deleteFromStorage = true
                        self.askAboutDeletion = false
                        self.journeyToDelete = ""
                    }
                    )
                }
                
            }
            
        }
        .onAppear {
            //List is updated every time the screen appears.
            self.clearInvalidJourneys()
            self.updateJourneys()
        }
        .refreshable {
            self.clearInvalidJourneys()
            self.updateJourneys()
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
                print("journey deleted successfully")
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
                        let deleteReference = FirebaseSetup.firebaseInstance.storage.reference().child("\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/\(self.journeyToDelete)/\(j)")
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
        if self.journeysList.count != 0 && self.journeysList[0].email != FirebaseSetup.firebaseInstance.auth.currentUser?.email {
            self.journeysList = []
        }
    }
    
    /**
     Function is responsible for adding journeys to array, and refreshing it if needed.
     */
    func updateJourneys() {
        let email = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? ""
        let path = "users/\(email)/friends/\(email)/journeys"
        
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if !self.journeysList.map({return $0.name}).contains(i.documentID) && i.documentID != "-" && !(i.get("deletedJourney") as! Bool) {
                        self.journeysList.append(SingleJourney(email: i.get("email") as! String, name: i.documentID, place: i.get("place") as! String, date: (i.get("date") as? Timestamp)?
                            .dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as! Int))
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for checking if journey occurs anywhere else in the database. If it doesn't, journey is ready to be deleted from storage as well.
     */
    func checkBeforeDeletion(journey: SingleJourney) {
        let friendsPath = "users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends"
        
        FirebaseSetup.firebaseInstance.db.collection(friendsPath).getDocuments { snapshot, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in snapshot!.documents {
                    if i.documentID != FirebaseSetup.firebaseInstance.auth.currentUser?.email {
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
