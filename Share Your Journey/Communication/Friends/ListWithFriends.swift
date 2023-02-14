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
                        self.populateFriends(completion: {
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
                for friend in querySnapshot!.documents {
                    if friend.documentID != currentUID && !self.friendsSet.friendsList.map({$0.uid}).contains(friend.documentID) && friend.get("deletedAccount") as? Bool ?? false == false {
                        self.friendsSet.friendsList.append(Person(nickname: friend.get("nickname") as? String ?? UIStrings.emptyString, uid: friend.documentID))
                    }
                }
            }
        }
    }
}
