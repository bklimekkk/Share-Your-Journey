//
//  ListWithRequests.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI

struct ListWithRequests: View {
    
    //variable contains data provided by users while searching lists.
    @Binding var searchPeople: String
    @Binding var requestsSet: RequestsSet
    var filteredRequestsList: [String]
    
    var body: some View {
        
        //List contains all requests searched by user.
        List (filteredRequestsList.sorted(by: {$0 < $1}), id: \.self) { request in
            HStack {
                Button{
                    removeRequest(request: request)
                } label: {
                    Image(systemName: "xmark")
                        .padding(5)
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text(request)
                    .padding(.vertical, 30)
                
                Spacer()
                
                Button{
                    acceptRequest(request: request)
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.green)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            populateRequests()
        }
        .refreshable {
            
            //Users are able to refresh list if any changes were made in the meantime.
            populateRequests()
        }
    }
    
    /**
     Function is responsible for searching server in order to return user list of requests sent to them.
     */
    func populateRequests() {
        
        //Variable controls which user is currently logged in into the application.
        let currentEmail = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? ""
        
        //Users can change account while being on the same phone. This statement detects it and refreshes the array accordingly.
        if requestsSet.ownEmail != currentEmail {
            requestsSet.requestsList = []
            requestsSet.ownEmail = currentEmail
        }
        
        //Program searches through requests collection in Firebase in order to fetch user's requests.
        FirebaseSetup.firebaseInstance.db.collection("users/\(currentEmail)/requests").getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if i.documentID != currentEmail && !requestsSet.requestsList.contains(i.documentID) {
                        requestsSet.requestsList.append(i.documentID)
                    }
                }
            }
        }
    }
    
    
    /**
     Function is responsible for removing requests picked by user.
     */
    func removeRequest(request: String) {
        
        //Chosen request is deleted from Firestore database.
        FirebaseSetup.firebaseInstance.db.collection("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/requests").document(request).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        
        //Request is deleted from the appropriate array.
        for i in 0...requestsSet.requestsList.count-1 {
            if requestsSet.requestsList[i] == request {
                requestsSet.requestsList.remove(at: i)
                break
            }
        }
    }
    
    /**
     Function responsible for accepting request sent to the user.
     */
    func acceptRequest(request: String) {
        
        //Email from which the request was sent from, is added to friends collection in Firestore database.
        FirebaseSetup.firebaseInstance.db.document("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(request)").setData([
            "email" : request,
            "deletedAccount" : false
        ])
        
        //Collection needs to contain at least one document in order to exist, so It's populated with one. This collection is going to contain qll journeys sent from user.
        FirebaseSetup.firebaseInstance.db.document("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(request)/journeys/-").setData([
            "name" : "-"
        ])
        
        //Program also needs to take care about adding user to their friend's "friends" collection.
        FirebaseSetup.firebaseInstance.db.document("users/\(request)/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")").setData([
            "email" : FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "",
            "deletedAccount" : false
        ])
        
        //This collection is going to contain all journeys sent to user.
        FirebaseSetup.firebaseInstance.db.document("users/\(request)/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys/-").setData([
            "name" : "-"
        ])
        
        //After request accepted, it needs to be deleted from requests array automatically.
        removeRequest(request: request)
    }
}
