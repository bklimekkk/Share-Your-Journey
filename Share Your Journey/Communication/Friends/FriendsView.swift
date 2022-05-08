//
//  FriendsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 12/02/2022.
//

import SwiftUI

//Struct responsible for creating a blueprint for variable containing all user's requests data.
struct RequestsSet {
    var ownEmail: String
    var requestsList: [String] = []
}

//Struct responsible for creating a blueprint for variable containing all user's friends data.
struct FriendsSet {
    var ownEmail: String
    var friendsList: [String] = []
}

struct FriendsView: View {
    
    //Variable responsible for justifying if users want to add new friend at the particular moment.
    @State private var addNewFriend = false
    
    //Variable checks if screen presents list with requests or list with friends.
    @State private var requestMode = false
    
    //Variable contains data entered by user while searching both arrays (requests and friends).
    @State private var searchPeople = ""
    
    //Variable contains detalis about user's requests.
    @State private var requestsSet = RequestsSet(ownEmail: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")
    
    //Variable will contain data necessary to populate array with user's friends.
    @State private var friendsSet = FriendsSet(ownEmail: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")
    
    //Variable is calculated by filtering arrays due to date they entered to search window.
    private var filteredRequestsList: [String] {
        if searchPeople.isEmpty {
            return requestsSet.requestsList
        } else {
            return requestsSet.requestsList.filter { $0.lowercased().contains(searchPeople.lowercased()) }
        }
    }
    
    //Variable will contain all user's friends filtered by text that user entered in search text field.
    private var filteredFriendsList: [String] {
        if searchPeople.isEmpty {
            return friendsSet.friendsList
        } else {
            return friendsSet.friendsList.filter { $0.lowercased().contains(searchPeople.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            
            //Screen allows users to view their friends list and list with requests sent to them.
            PickerView(choice: $requestMode, firstChoice: "Friends", secondChoice: "Requests")
                .padding()
            
            SearchField(text: "Search e-mail address", search: $searchPeople)
            
            //Depending on what option user has chosen, different lists are persented.
            if requestMode {
               ListWithRequests(searchPeople: $searchPeople, requestsSet: $requestsSet, filteredRequestsList: filteredRequestsList)
            } else {
                ListWithFriends(searchPeople: $searchPeople, friendsSet: $friendsSet, filteredFriendsList: filteredFriendsList)
            }
            Spacer()
            Button {
                addNewFriend = true
            } label: {
                ButtonView(buttonTitle: "Add a new friend")
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
        .padding(.bottom)
        .sheet(isPresented: $addNewFriend, onDismiss: nil) {
            AddFriendView(sheetIsPresented: $addNewFriend)
        }
    }
}
