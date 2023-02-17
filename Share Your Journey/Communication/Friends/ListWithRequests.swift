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
    var filteredSortedRequestsList: [Person]
    
    var body: some View {
        
        VStack {
            if !self.loadedRequests {
                LoadingView()
            } else if self.filteredSortedRequestsList.isEmpty {
                NoDataView(text: UIStrings.noRequestsToShow)
                    .onTapGesture {
                        self.loadedRequests = false
                        self.populateRequests(completion: {
                            self.loadedRequests = true
                        })
                    }
            } else {
                //List contains all requests searched by user.
                List {
                    ForEach(self.filteredSortedRequestsList, id: \.self) { request in
                    HStack {
                        Text(request.nickname)
                            .bold()
                            .padding(.vertical, 15)
                        Spacer()
                        Button {
                            self.acceptRequest(request: request)
                        } label: {
                            Image(systemName: Icons.checkmark)
                                .foregroundColor(Color.green)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                    .onDelete(perform: self.delete)
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
                for request in querySnapshot!.documents {
                    if request.documentID != currentUID && !self.requestsSet.requestsList.map({$0.uid}).contains(request.documentID) {
                        self.requestsSet.requestsList.append(Person(nickname: request.get("nickname") as? String ?? UIStrings.emptyString, uid: request.documentID))
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
        self.requestsSet.requestsList.removeAll(where: {$0.uid == request.uid})
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
            "nickname" : UserDefaults.standard.string(forKey: "nickname") ?? UIStrings.emptyString,
            "deletedAccount" : false
        ])
        
        //After request accepted, it needs to be deleted from requests array automatically.
        self.removeRequest(request: request)
        self.notificationSetup.notificationType = .none
    }

    func delete(at offsets: IndexSet) {
        self.removeRequest(request: self.filteredSortedRequestsList[offsets[offsets.startIndex]])
    }
}
