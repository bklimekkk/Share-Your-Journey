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
    @State private var loadedFriends = false
    var filteredFriendsList: [String]
    
    var body: some View {
        VStack {
            if !self.loadedFriends {
                LoadingView()
            } else if self.filteredFriendsList.isEmpty {
                NoDataView(text: UIStrings.noFriendsToShow)
                    .onTapGesture {
                        self.loadedFriends = false
                        self.populateFriends(completion: {
                            self.loadedFriends = true
                        })
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
                            NavigationLink(destination: ChatView(uid: friend)) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.plain)
                .refreshable {
                    self.populateFriends(completion: {
                        self.loadedFriends = true
                    })
                }
            }
        }
        //Array is populated after the screen is shown, but users are also able to refresh the list by dragging it down (thanks to .refreshable).
        .onAppear {
            self.populateFriends(completion: {
                self.loadedFriends = true
            })
        }
    }
    
    /**
     Function is responsible for pulling data about user's friends from the server and populating the friends array with it.
     */
    func populateFriends(completion: @escaping() -> Void) {
        
        //This block of code ensures that users that are currently logged in, will see their own friends list (even after logging out).
        let currentUID = Auth.auth().currentUser?.uid ?? UIStrings.emptyString
        if self.friendsSet.ownUID != currentUID {
            self.friendsSet.friendsList = []
            self.friendsSet.ownUID = currentUID
        }
        
        //Data is pulled out of the appropriate collection in firestore database and array is populated with it.
        Firestore.firestore().collection(FirestorePaths.getFriends(uid: currentUID)).getDocuments { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if i.documentID != currentUID && !self.friendsSet.friendsList.contains(i.documentID) && i.get("deletedAccount") as? Bool ?? false == false {
                        self.friendsSet.friendsList.append(i.documentID)
                    }
                }
            }
        }
    }
}
