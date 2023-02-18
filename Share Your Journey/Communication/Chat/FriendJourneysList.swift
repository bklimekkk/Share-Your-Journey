//
//  FriendJourneysList.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
import Firebase

//Code in this struct is responsible for showing users list of journeys sent by their friends.
struct FriendJourneysList: View {
    
    //Variables described in ChatView struct.
    @Binding var searchJourney: String
    @Binding var sentByFriend: [SingleJourney]
    @State private var loadedFriendsJourneys = false
    @EnvironmentObject var notificationSetup: NotificationSetup

    private var sentByFriendFilteredSorted: [SingleJourney] {
        if self.searchJourney == "" {
            return self.sentByFriend
                .sorted(by: {$0.operationDate > $1.operationDate})
        } else {
            return self.sentByFriend
                .filter({return $0.place.lowercased().contains(self.searchJourney.lowercased())})
                .sorted(by: {$0.operationDate > $1.operationDate})
        }
    }
    
    //Friend's uid
    var uid: String
    
    var body: some View {
        VStack {
            if !self.loadedFriendsJourneys {
                LoadingView()
            } else if self.sentByFriendFilteredSorted.isEmpty {
                NoDataView(text: UIStrings.noJourneysToShowTapToRefresh)
                    .onTapGesture {
                        self.loadedFriendsJourneys = false
                        self.populateFriendsJourneys(completion: {
                            self.loadedFriendsJourneys = true
                        })
                    }
            } else {
                //List presenting users with journeys sent by their friends.
                List {
                    ForEach (self.sentByFriendFilteredSorted, id: \.self) { journey in
                        ZStack {
                            HStack {
                                Text(journey.place)
                                    .bold()
                                    .padding(.vertical, 15)
                                Spacer()
                                Text(DateManager.getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }
                            //NavigationLink's destination property is set to struct responsible for showing the relevant journey.
                            NavigationLink(destination: SeeJourneyView(journey: journey,
                                                                       uid: self.uid,
                                                                       downloadMode: false,
                                                                       path: "\(FirestorePaths.getFriends(uid: self.uid))/\(Auth.auth().currentUser?.uid ?? "")/journeys")) {
                                EmptyView()
                            }
                                                                       .opacity(0)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.inset)
                .refreshable {
                    self.populateFriendsJourneys(completion: {
                        self.loadedFriendsJourneys = true
                    })
                }
            }
        }
        .onAppear {
            self.sentByFriend = []
            self.populateFriendsJourneys(completion: {
                self.loadedFriendsJourneys = true
            })
            self.notificationSetup.notificationType = .none
            self.notificationSetup.sender = ""
        }
    }
    
    /**
     Function is responsible for populating the array with journeys sent by friend.
     */
    func populateFriendsJourneys(completion: @escaping () -> Void) {
        let path = "\(FirestorePaths.getFriends(uid: self.uid))/\(Auth.auth().currentUser?.uid ?? "")/journeys"
        Firestore.firestore().collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let receivedJourneys = querySnapshot!.documents
                for journey in receivedJourneys {
                    if !self.sentByFriend.map({return $0.name}).contains(journey.documentID) && !(journey.get("deletedJourney") as? Bool ?? false) {
                        self.sentByFriend.append(SingleJourney(uid: uid,
                                                               name: journey.documentID,
                                                               place: journey.get("place") as? String ?? "",
                                                               date: (journey.get("date") as? Timestamp)?.dateValue() ?? Date.now,
                                                               operationDate: (journey.get("operationDate") as? Timestamp)?.dateValue() ?? Date.now,
                                                               numberOfPhotos: journey.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
                self.sentByFriend.removeAll(where: {!receivedJourneys.map({return $0.documentID}).contains($0.name)})
            }
        }
    }
}
