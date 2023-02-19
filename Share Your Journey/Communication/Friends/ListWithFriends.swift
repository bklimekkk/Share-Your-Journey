//
//  ListWithFriends.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
import Firebase

//Struct contains code responsible for generating list of user's friends.
struct ListWithFriends: View {
    @Binding var searchPeople: String
    @Binding var friendsSet: FriendsSet
    @Binding var loadedFriends: Bool
    @State private var showJourneyFromNotification = false
    @EnvironmentObject var notificationSetup: NotificationSetup
    var filteredSortedFriendsList: [Person]
    
    var body: some View {
        VStack {
            if !self.loadedFriends {
                LoadingView()
            } else if self.filteredSortedFriendsList.isEmpty {
                NoDataView(text: UIStrings.noFriendsToShow)
                    .onTapGesture {
                        self.loadedFriends = false
                        FriendsManager(friendsSet: self.$friendsSet).populateFriends(completion: {
                            self.loadedFriends = true
                        })
                    }
            } else {
                //List is sorted alphabetically.
                List (self.filteredSortedFriendsList, id: \.self) { friend in
                    ZStack {
                        HStack {
                            Text(friend.nickname)
                                .bold()
                                .padding(.vertical, 15)
                            Spacer()
                        }
                        NavigationLink(destination: ChatView(uid: friend.uid, nickname: friend.nickname).environmentObject(self.notificationSetup),
                                       tag: friend.nickname,
                                       selection: self.$notificationSetup.sender) {
                            EmptyView()
                        }
                                       .opacity(0)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.plain)
                .refreshable {
                    FriendsManager(friendsSet: self.$friendsSet).populateFriends(completion: {
                        self.loadedFriends = true
                    })
                }
            }
        }
    }
}
