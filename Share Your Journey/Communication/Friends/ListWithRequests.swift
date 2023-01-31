//
//  ListWithRequests.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
import Firebase

struct ListWithRequests: View {
    
    //variable contains data provided by users while searching lists.
    @Binding var searchPeople: String
    @Binding var requestsSet: RequestsSet
    @State private var loadedRequests = false
    @EnvironmentObject var notificationSetup: NotificationSetup
    var filteredRequestsList: [Person]
    
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
                List (self.filteredRequestsList.sorted(by: {$0.nickname < $1.nickname}), id: \.self) { request in
                    HStack {
                        Button{
                            self.removeRequest(request: request)
                        } label: {
                            Image(systemName: Icons.xmark)
                                .padding(5)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Text(request.nickname)
                            .bold()
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
        let currentUID = Auth.auth().currentUser?.uid ?? UIStrings.emptyString
        
        //Users can change account while being on the same phone. This statement detects it and refreshes the array accordingly.
        if self.requestsSet.ownUID != currentUID {
            self.requestsSet.requestsList = []
            self.requestsSet.ownUID = currentUID
        }
        
        //Program searches through requests collection in Firebase in order to fetch user's requests.
        Firestore.firestore().collection(FirestorePaths.getRequests(uid: currentUID)).getDocuments { (querySnapshot, error) in
            completion()
            if error != nil {
                print(error!.localizedDescription)
            } else {
                for i in querySnapshot!.documents {
                    if i.documentID != currentUID && !self.requestsSet.requestsList.map({$0.uid}).contains(i.documentID) {
                        self.requestsSet.requestsList.append(Person(nickname: i.get("nickname") as? String ?? UIStrings.emptyString, uid: i.documentID))
                    }
                }
            }
        }
    }
    
    /**
     Function is responsible for removing requests picked by user.
     */
    func removeRequest(request: Person) {
        
        //Chosen request is deleted from Firestore database.
        Firestore.firestore().collection(FirestorePaths.getRequests(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString)).document(request.uid).delete() { error in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
        
        //Request is deleted from the appropriate array.
        for i in 0...self.requestsSet.requestsList.count - 1 {
            if self.requestsSet.requestsList[i].uid == request.uid {
                self.requestsSet.requestsList.remove(at: i)
                break
            }
        }
    }
    
    /**
     Function responsible for accepting request sent to the user.
     */
    func acceptRequest(request: Person) {
        
        //UID of account from which the request was sent from, is added to friends collection in Firestore database.
        Firestore.firestore().document("\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString))/\(request.uid)").setData([
            "uid" : request.uid,
            "nickname" : request.nickname,
            "deletedAccount" : false
        ])
        
        //Program also needs to take care about adding user to their friend's "friends" collection.
        Firestore.firestore().document("\(FirestorePaths.getFriends(uid: request.uid))/\(Auth.auth().currentUser?.uid ?? UIStrings.emptyString)").setData([
            "uid" : Auth.auth().currentUser?.uid ?? UIStrings.emptyString,
            "nickname" : UserSettings.shared.nickname,
            "deletedAccount" : false
        ])
        
        //After request accepted, it needs to be deleted from requests array automatically.
        self.removeRequest(request: request)
        self.notificationSetup.notificationType = .none
    }
}
