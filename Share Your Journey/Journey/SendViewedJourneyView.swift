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
    @State private var listOfFriends: [Person] = []
    var uid: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(self.listOfFriends.sorted(by: {$0.nickname < $1.nickname}), id: \.self) { friend in
                        Text(friend.nickname)
                            .padding(.vertical, 15)
                            .onTapGesture {
                                SendJourneyManager().sendJourney(journey: self.journey, targetUID: friend.uid)
                                withAnimation {
                                    self.listOfFriends.removeAll(where: {$0 == friend})
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(UIStrings.availableRecipients)
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
            .task {
                self.getFriends { friends in
                    friends.forEach { friend in
                        getSentJourneys(friend: friend.uid) { alreadySent in
                            if !alreadySent {
                                self.listOfFriends.append(friend)
                            }
                        }
                    }
                }
            }
        }
    }

    func getFriends(completion: @escaping([Person]) -> Void) {
        Firestore.firestore().collection(FirestorePaths.getFriends(uid: self.uid)).getDocuments { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion([])
            } else {
                let documents = querySnapshot!.documents
                    .filter({$0.documentID != self.uid})
                    .map({Person(nickname: $0.get("nickname") as? String ?? "", uid: $0.documentID)})
                completion(documents)
            }
        }
    }

    func getSentJourneys(friend: String, completion: @escaping(Bool) -> Void) {
        Firestore.firestore().collection("\(FirestorePaths.getFriends(uid: self.uid))/\(friend)/journeys").getDocuments() { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion(true)
            } else {
                completion(querySnapshot!.documents.first(where: {$0.documentID == self.journey.name}) != nil)
            }
        }
    }
}


