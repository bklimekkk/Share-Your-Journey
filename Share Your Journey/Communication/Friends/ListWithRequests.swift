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
    @State private var loadedRequests = false
    var filteredRequestsList: [String]
    
    var body: some View {
        
        VStack {
            if !self.loadedRequests {
                LoadingView()
            } else if self.filteredRequestsList.isEmpty {
                NoDataView(text: UIStrings.noRequestsToShow)
                    .onTapGesture {
                        self.loadedRequests = false
                        self.populateRequests(completion: {
                            self.loadedRequests = true
                        })
                    }
            } else {
                //List contains all requests searched by user.
                List (self.filteredRequestsList.sorted(by: {$0 < $1}), id: \.self) { request in
                    HStack {
                        Button{
                            self.removeRequest(request: request)
                        } label: {
                            Image(systemName: Icons.xmark)
                                .padding(5)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Text(request)
                            .padding(.vertical, 15)
                        Spacer()
                        Button{
                            self.acceptRequest(request: request)
                        } label: {
                            Image(systemName: Icons.checkmark)
                                .foregroundColor(Color.green)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.inset)
                .navigationBarHidden(true)
                .refreshable {
                    //Users are able to refresh list if any changes were made in the meantime.
                    self.populateRequests(completion: {
                        self.loadedRequests = true
                    })
                }
            }
        }
        .onAppear {
            self.populateRequests(completion: {
                self.loadedRequests = true
            })
        }
    }
    
    /**
     Function is responsible for searching server in order to return user list of requests sent to them.
     */
    func populateRequests(completion: @escaping() -> Void) {
        
        //Variable controls which user is currently logged in into the application.
        let currentEmail = FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString
        
        //Users can change account while being on the same phone. This statement detects it and refreshes the array accordingly.
        if self.requestsSet.ownEmail != currentEmail {
            self.requestsSet.requestsList = []
            self.requestsSet.ownEmail = currentEmail
        }
        
        //Program searches through requests collection in Firebase in order to fetch user's requests.
        FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getRequests(email: currentEmail)).getDocuments { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if i.documentID != currentEmail && !self.requestsSet.requestsList.contains(i.documentID) {
                        self.requestsSet.requestsList.append(i.documentID)
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
        FirebaseSetup.firebaseInstance.db.collection(FirestorePaths.getRequests(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)).document(request).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        
        //Request is deleted from the appropriate array.
        for i in 0...self.requestsSet.requestsList.count - 1 {
            if self.requestsSet.requestsList[i] == request {
                self.requestsSet.requestsList.remove(at: i)
                break
            }
        }
    }
    
    /**
     Function responsible for accepting request sent to the user.
     */
    func acceptRequest(request: String) {
        
        //Email from which the request was sent from, is added to friends collection in Firestore database.
        FirebaseSetup.firebaseInstance.db.document("\(FirestorePaths.getFriends(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString))/\(request)").setData([
            "email" : request,
            "deletedAccount" : false
        ])
        
        //Collection needs to contain at least one document in order to exist, so It's populated with one. This collection is going to contain qll journeys sent from user.
        FirebaseSetup.firebaseInstance.db.document("\(FirestorePaths.getFriends(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString))/\(request)/journeys/-").setData([
            "name" : "-"
        ])
        
        //Program also needs to take care about adding user to their friend's "friends" collection.
        FirebaseSetup.firebaseInstance.db.document("\(FirestorePaths.getFriends(email: request))/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)").setData([
            "email" : FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString,
            "deletedAccount" : false
        ])
        
        //This collection is going to contain all journeys sent to user.
        FirebaseSetup.firebaseInstance.db.document("\(FirestorePaths.getFriends(email: request))/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys/-").setData([
            "name" : "-"
        ])
        
        //After request accepted, it needs to be deleted from requests array automatically.
        self.removeRequest(request: request)
    }
}
