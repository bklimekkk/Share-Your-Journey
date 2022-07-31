//
//  SendViewedJourneyView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 31/07/2022.
//

import SwiftUI
import Firebase

struct SendViewedJourneyView: View {
    var journey: SingleJourney
    @Environment(\.dismiss) var dismiss
    @State private var listOfFriends: [String] = []
    @State private var showDuplicationAlert = false
    @State private var sendDuplicate = false
    var email: String {
        FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? ""
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(listOfFriends, id: \.self) { friend in
                    Text(friend)
                        .onTapGesture {
                            
                            
                            
                            FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(friend)/journeys").getDocuments { querySnapshot, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    if querySnapshot!.documents.map({$0.documentID}).contains(journey.name) {
                                        showDuplicationAlert = true
                                    } else {
                                        SendJourneyManager().sendJourney(journey: journey, targetEmail: friend)
                                        withAnimation {
                                            for i in 0...listOfFriends.count - 1 {
                                                if listOfFriends[i] == friend {
                                                    listOfFriends.remove(at: i)
                                                    break
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                    
                    
                }
                
            }
            .navigationTitle("Choose recipients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Duplicate journey", isPresented: $showDuplicationAlert, actions: {
                Button("Ok", role: .cancel){ }
            },message: {
                Text("You have already sent this journey to this person.")
            })
            .task {
                FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends").getDocuments { querySnapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        for i in querySnapshot!.documents {
                            if i.documentID != email {
                                FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(i)/journeys").getDocuments() { querySnapshot, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        if !querySnapshot!.documents.map({$0.documentID}).contains(journey.name) {
                                            listOfFriends.append(i.documentID)
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

