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
    @EnvironmentObject var notificationSetup: NotificationSetup
    //Variables described in ChatView struct.
    @Binding var searchJourney: String
    @Binding var sentByFriend: [SingleJourney]
    @Binding var loadedFriendsJourneys: Bool

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
                        SentByFriendManager(list: self.$sentByFriend).populateFriendsJourneys(uid: self.uid) {
                            self.loadedFriendsJourneys = true
                        }
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
                    SentByFriendManager(list: self.$sentByFriend).populateFriendsJourneys(uid: self.uid) {
                        self.loadedFriendsJourneys = true
                    }
                }
            }
        }
    }
}
