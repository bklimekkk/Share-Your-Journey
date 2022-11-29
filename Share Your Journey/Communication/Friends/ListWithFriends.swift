//
//  ListWithFriends.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI

//Struct contains code responsible for generating list of user's friends.
struct ListWithFriends: View {
    @Binding var searchPeople: String
    @Binding var friendsSet: FriendsSet
    var filteredFriendsList: [String]
    
    var body: some View {
        VStack {
            
            if self.filteredFriendsList.isEmpty {
                NoDataView(text: "No friends to show. Tap to refresh.")
                    .onTapGesture {
                        self.populateFriends()
                    }
            } else {
                //List is sorted alphabetically.
                List {
                    ForEach (self.filteredFriendsList.sorted(by: {$0 < $1}), id: \.self) { friend in
                        ZStack {
                            HStack {
                                Text(friend)
                                    .padding(.vertical, 15)
                                Spacer()
                            }

                            NavigationLink(destination: ChatView(email: friend)) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    self.populateFriends()
                }
            }
        }
        //Array is populated after the screen is shown, but users are also able to refresh the list by dragging it down (thanks to .refreshable).
        .onAppear {
            self.populateFriends()
        }
    }
    
    /**
     Function is responsible for pulling data about user's friends from the server and populating the friends array with it.
     */
    func populateFriends() {
        
        //This block of code ensures that users that are currently logged in, will see their own friends list (even after logging out).
        let currentEmail = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? ""
        if self.friendsSet.ownEmail != currentEmail {
            self.friendsSet.friendsList = []
            self.friendsSet.ownEmail = currentEmail
        }
        
        //Data is pulled out of the appropriate collection in firestore database and array is populated with it.
        FirebaseSetup.firebaseInstance.db.collection("users/\(currentEmail)/friends").getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if i.documentID != currentEmail && !self.friendsSet.friendsList.contains(i.documentID) && i.get("deletedAccount") as! Bool == false {
                        self.friendsSet.friendsList.append(i.documentID)
                    }
                }
            }
        }
    }
}
