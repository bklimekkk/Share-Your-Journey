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
    @Binding var loadedRequests: Bool
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
                        RequestsManager(requestsSet: self.$requestsSet).populateRequests(completion: {
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
                            RequestsManager(requestsSet: self.$requestsSet).acceptRequest(request: request)
                            self.notificationSetup.notificationType = .none
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
                    RequestsManager(requestsSet: self.$requestsSet).populateRequests(completion: {
                        self.loadedRequests = true
                    })
                }
            }
        }
    }

    func delete(at offsets: IndexSet) {
        RequestsManager(requestsSet: self.$requestsSet).removeRequest(request: self.filteredSortedRequestsList[offsets[offsets.startIndex]])
    }
}
