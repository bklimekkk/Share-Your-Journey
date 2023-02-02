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
    var uid: String {
        Auth.auth().currentUser?.uid ?? UIStrings.emptyString
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(self.listOfFriends.sorted(by: {$0 < $1}), id: \.self) { friend in
                    Text(friend)
                        .padding(.vertical, 15)
                        .onTapGesture {
                            Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: self.uid))/\(friend)/journeys").getDocuments { querySnapshot, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    if querySnapshot!.documents.map({$0.documentID}).contains(self.journey.name) {
                                        self.showDuplicationAlert = true
                                        
                                    } else {
                                        SendJourneyManager().sendJourney(journey: self.journey, targetUID: friend)

                                        if self.listOfFriends.count > 0 {
                                            withAnimation {
                                                self.listOfFriends.removeAll(where: {$0 == friend})
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
                
            }
            .listStyle(.plain)
            .navigationTitle(UIStrings.chooseRecipients)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        self.dismiss()
                    } label: {
                        SheetDismissButtonView()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(UIStrings.done) {
                        self.dismiss()
                    }
                }
            }
            .alert(UIStrings.duplicateJourney, isPresented: self.$showDuplicationAlert, actions: {
                Button(UIStrings.ok, role: .cancel){ }
            },message: {
                Text(UIStrings.journeyAlreadyExists)
            })
            .task {
                Firestore.firestore().collection(FirestorePaths.getFriends(uid: self.uid)).getDocuments { querySnapshot, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        for friend in querySnapshot!.documents {
                            if friend.documentID != self.uid {
                                Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: self.uid))/\(friend)/journeys").getDocuments() { querySnapshot, error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        if !querySnapshot!.documents.map({$0.documentID}).contains(self.journey.name) {
                                            self.listOfFriends.append(friend.documentID)
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

