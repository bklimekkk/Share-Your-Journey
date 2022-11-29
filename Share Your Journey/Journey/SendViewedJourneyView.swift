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
                ForEach(self.listOfFriends.sorted(by: {$0 < $1}), id: \.self) { friend in
                    Text(friend)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            FirebaseSetup.firebaseInstance.db.collection("users/\(email)/friends/\(friend)/journeys").getDocuments { querySnapshot, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    if querySnapshot!.documents.map({$0.documentID}).contains(self.journey.name) {
                                        self.showDuplicationAlert = true

                                    } else {
                                        SendJourneyManager().sendJourney(journey: self.journey, targetEmail: friend)
                                        withAnimation {
                                            for i in 0...self.listOfFriends.count - 1 {
                                                if self.listOfFriends[i] == friend {
                                                    self.listOfFriends.remove(at: i)
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
            .listStyle(.plain)
            .navigationTitle("Choose recipients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        self.dismiss()
                    }
                }
            }
            .alert("Duplicate journey", isPresented: self.$showDuplicationAlert, actions: {
                Button("Ok", role: .cancel){ }
            },message: {
                Text("This journey already exists in your conversation with this person.")
            })
            .task {
                FirebaseSetup.firebaseInstance.db.collection("users/\(self.email)/friends").getDocuments { querySnapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        for i in querySnapshot!.documents {
                            if i.documentID != self.email {
                                FirebaseSetup.firebaseInstance.db.collection("users/\(self.email)/friends/\(i)/journeys").getDocuments() { querySnapshot, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        if !querySnapshot!.documents.map({$0.documentID}).contains(self.journey.name) {
                                            self.listOfFriends.append(i.documentID)
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

