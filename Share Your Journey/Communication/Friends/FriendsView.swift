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
    
    //Variable checks if screen presents list with requests or list with friends.
    @State private var requestMode = false
    //Variable responsible for justifying if users want to add new friend at the particular moment.
    @State private var addNewFriend = false
    //Variable contains detalis about user's requests.
    @State private var requestsSet = RequestsSet(ownUID: Auth.auth().currentUser?.uid ?? UIStrings.emptyString)
    //Variable will contain data necessary to populate array with user's friends.
    @State private var friendsSet = FriendsSet(ownUID: Auth.auth().currentUser?.uid ?? UIStrings.emptyString)
    //Variable conains data entered by user while searching both arrays (requests and friends).
    @State private var searchPeople = UIStrings.emptyString
    @EnvironmentObject var notificationSetup: NotificationSetup
    //Variable is calculated by filtering arrays due to date they entered to search window.
    private var filteredRequestsList: [Person] {
        if self.searchPeople.isEmpty {
            return self.requestsSet.requestsList
        } else {
            return self.requestsSet.requestsList.filter { $0.nickname.lowercased().contains(self.searchPeople.lowercased()) }
        }
    }
    
    //Variable will contain all user's friends filtered by text that user entered in search text field.
    private var filteredFriendsList: [Person] {
        if self.searchPeople.isEmpty {
            return self.friendsSet.friendsList
        } else {
            return self.friendsSet.friendsList.filter { $0.nickname.lowercased().contains(searchPeople.lowercased()) }
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
                                 filteredRequestsList: self.filteredRequestsList)
                .environmentObject(notificationSetup)
            } else {
                ListWithFriends(searchPeople: self.$searchPeople,
                                friendsSet: self.$friendsSet,
                                filteredFriendsList: self.filteredFriendsList)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 5)
        }
        .onAppear {
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
