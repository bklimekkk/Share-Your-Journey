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
    var sentByFriendFiltered: [SingleJourney]
    
    var sentByFriendFilteredSorted: [SingleJourney] {
        return sentByFriendFiltered.sorted(by: {$0.operationDate > $1.operationDate})
    }
    
    //Friend's e-mail address.
    var email: String
    
    var body: some View {
        VStack {
            if !self.loadedFriendsJourneys {
                LoadingView()
            } else if self.sentByFriendFiltered.isEmpty {
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
                                    .padding(.vertical, 15)
                                Spacer()
                                Text(DateManager.getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }
                            //NavigationLink's destination property is set to struct responsible for showing the relevant journey.
                            NavigationLink(destination: SeeJourneyView(journey: journey, email: self.email, downloadMode: false, path: "\(FirestorePaths.getFriends(email: self.email))/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)/journeys")){
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
        }
    }
    
    /**
     Function is responsible for populating the array with journeys sent by friend.
     */
    func populateFriendsJourneys(completion: @escaping () -> Void) {
        let path = "\(FirestorePaths.getFriends(email: self.email))/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)/journeys"
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments() { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                let receivedJourneys = querySnapshot!.documents
                for i in receivedJourneys {
                    if !self.sentByFriend.map({return $0.name}).contains(i.documentID) && i.documentID != "-" && !(i.get("deletedJourney") as? Bool ?? false) {
                        self.sentByFriend.append(SingleJourney(email: email,
                                                               name: i.documentID,
                                                               place: i.get("place") as? String ?? UIStrings.emptyString,
                                                               date: (i.get("date") as? Timestamp)?.dateValue() ?? Date.now,
                                                               operationDate: (i.get("operationDate") as? Timestamp)?.dateValue() ?? Date.now,
                                                               numberOfPhotos: i.get("photosNumber") as? Int ?? IntConstants.defaultValue))
                    }
                }
                if self.sentByFriend.count > 0 {
                    for i in 0...self.sentByFriend.count - 1 {
                        if !receivedJourneys.map({return $0.documentID}).contains(self.sentByFriend[i].name) {
                            self.sentByFriend.remove(at: i)
                            break
                        }
                    }
                }
            }
        }
    }
}
