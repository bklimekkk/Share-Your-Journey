//
//  FriendsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 12/02/2022.
//

import SwiftUI
import Firebase

struct Person: Hashable {
    let nickname: String
    let uid: String
}
//Struct responsible for creating a blueprint for variable containing all user's requests data.
struct RequestsSet {
    var ownUID: String
    var requestsList: [Person] = []
}

//Struct responsible for creating a blueprint for variable containing all user's friends data.
struct FriendsSet {
    var ownUID: String
    var friendsList: [Person] = []
}

struct FriendsView: View {

    @EnvironmentObject var notificationSetup: NotificationSetup

    //Variable checks if screen presents list with requests or list with friends.
    @State private var requestMode = false
    //Variable responsible for justifying if users want to add new friend at the particular moment.
    @State private var addNewFriend = false
    //Variable contains detalis about user's requests.
    @State private var requestsSet = RequestsSet(ownUID: Auth.auth().currentUser?.uid ?? "")
    //Variable will contain data necessary to populate array with user's friends.
    @State private var friendsSet = FriendsSet(ownUID: Auth.auth().currentUser?.uid ?? "")
    //Variable conains data entered by user while searching both arrays (requests and friends).
    @State private var searchPeople = ""
    @State private var loadedFriends = false
    @State private var loadedRequests = false

    //Variable is calculated by filtering arrays due to date they entered to search window.
    private var filteredSortedRequestsList: [Person] {
        if self.searchPeople.isEmpty {
            return self.requestsSet.requestsList
                .sorted(by: {$0.nickname < $1.nickname})
        } else {
            return self.requestsSet.requestsList.filter { $0.nickname.lowercased().contains(self.searchPeople.lowercased()) }
                .sorted(by: {$0.nickname < $1.nickname})
        }
    }
    
    //Variable will contain all user's friends filtered by text that user entered in search text field.
    private var filteredSortedFriendsList: [Person] {
        if self.searchPeople.isEmpty {
            return self.friendsSet.friendsList
                .sorted(by: {$0.nickname < $1.nickname})
        } else {
            return self.friendsSet.friendsList.filter { $0.nickname.lowercased().contains(searchPeople.lowercased()) }
                .sorted(by: {$0.nickname < $1.nickname})
        }
    }
    
    var body: some View {
        
        VStack (spacing: 0) {
            //Screen allows users to view their friends list and list with requests sent to them.
            PickerView(choice: self.$requestMode,
                       firstChoice: UIStrings.friends,
                       secondChoice: UIStrings.requests)
            .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
            
            SearchField(text: UIStrings.searchNickname, search: self.$searchPeople)
            
            //Depending on what option user has chosen, different lists are persented.
            if self.requestMode {
                ListWithRequests(searchPeople: self.$searchPeople,
                                 requestsSet: self.$requestsSet,
                                 loadedRequests: self.$loadedRequests,
                                 filteredSortedRequestsList: self.filteredSortedRequestsList)
                .environmentObject(notificationSetup)
            } else {
                ListWithFriends(searchPeople: self.$searchPeople,
                                friendsSet: self.$friendsSet,
                                loadedFriends: self.$loadedFriends,
                                filteredSortedFriendsList: self.filteredSortedFriendsList)
                .environmentObject(notificationSetup)
            }
            Divider()
            Spacer()
            Button {
                self.addNewFriend = true
            } label: {
                ButtonView(buttonTitle: UIStrings.addANewFriend)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .padding(.horizontal, 5)
        }
        .onAppear {
            FriendsManager(friendsSet: self.$friendsSet).populateFriends(completion: {
                self.loadedFriends = true
            })
            RequestsManager(requestsSet: self.$requestsSet).populateRequests(completion: {
                self.loadedRequests = true
            })
            if self.notificationSetup.notificationType == .invitation {
                self.requestMode = true
            }
        }
        .onChange(of: self.notificationSetup.notificationType, perform: { newValue in
            if newValue == .invitation {
                self.requestMode = true
            }
        })
        .padding(.bottom, 5)
        .sheet(isPresented: self.$addNewFriend, onDismiss: nil) {
            AddFriendView(sheetIsPresented: self.$addNewFriend)
        }
        
    }
}
