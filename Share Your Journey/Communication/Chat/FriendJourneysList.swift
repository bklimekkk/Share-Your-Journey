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
    
    var sentByFriendFiltered: [SingleJourney]
    
    //Friend's e-mail address.
    var email: String
    
    var body: some View {
        VStack {
            if sentByFriendFiltered.isEmpty{
                NoDataView(text: "No journeys to show. Tap to refresh.")
                    .onTapGesture {
                        populateFriendsJourneys()
                    }
            } else {
                //List presenting users with journeys sent by their friends.
                List(sentByFriendFiltered.sorted(by: {$0.date > $1.date}), id: \.self) { journey in
                    
                    //NavigationLink's destination property is set to struct responsible for showing the relevant journey.
                    NavigationLink(destination: SeeJourneyView(journey: journey, email: email, downloadMode: false, path: "users/\(email)/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys")) {
                        Text(journey.name)
                            .padding(.vertical, 30)
                    }
                }
                
                .refreshable {
                    populateFriendsJourneys()
                }
            }
        }
        .onAppear {
            populateFriendsJourneys()
        }
    }
    
    /**
     Function is responsible for populating the array with journeys sent by friend.
     */
    func populateFriendsJourneys() {
        let path = "users/\(email)/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys"
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments() { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                let receivedJourneys = querySnapshot!.documents
                for i in receivedJourneys {
                    if !sentByFriend.map({return $0.name}).contains(i.documentID) && i.documentID != "-" && !(i.get("deletedJourney") as! Bool) {
                        sentByFriend.append(SingleJourney(email: email, name: i.documentID, date: (i.get("date") as? Timestamp)?.dateValue() ?? Date(), numberOfPhotos: i.get("photosNumber") as! Int, photos: [], photosLocations: []))
                    }
                }
                
                if sentByFriend.count > 0 {
                    for i in 0...sentByFriend.count - 1 {
                        if !receivedJourneys.map({return $0.documentID}).contains(sentByFriend[i].name) {
                            sentByFriend.remove(at: i)
                            break
                        }
                    }
                }
            }
        }
    }
}
