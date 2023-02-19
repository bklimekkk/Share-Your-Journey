//
//  YourJourneysList.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
import Firebase

//Struct contains code responsible for generating list with user's journeys in a chat with friend.
struct YourJourneysList: View {
    
    //Variables described in ChatView struct.
    @Binding var searchJourney: String
    @Binding var sendJourneyScreen: Bool
    @Binding var askAboutDeletion: Bool
    @Binding var sentByYou: [SingleJourney]
    @Binding var loadedYourJourneys: Bool
    //Variable is supposed to contain name of the journey that currently is supposed to be deleted.
    @State private var journeyToDelete = SingleJourney()
    //Friend's uid.
    var uid: String

    var sentByYouFilteredSorted: [SingleJourney] {
        if self.searchJourney == "" {
            return self.sentByYou
                .sorted(by: {$0.operationDate > $1.operationDate})
        } else {
            return self.sentByYou
                .filter({return $0.place.lowercased().contains(self.searchJourney.lowercased())})
                .sorted(by: {$0.operationDate > $1.operationDate})
        }
    }

    var body: some View {
        
        VStack {
            if !self.loadedYourJourneys {
                LoadingView()
            } else if self.sentByYouFilteredSorted.isEmpty {
                NoDataView(text: UIStrings.noJourneysToShowTapToRefresh)
                    .onTapGesture {
                        self.loadedYourJourneys = false
                        SentByYouManager(list: self.$sentByYou).populateYourJourneys(uid: self.uid) {
                            self.loadedYourJourneys = true
                        }
                    }
            } else {
                //List is sorted by date.
                List {
                    ForEach (self.sentByYouFilteredSorted, id: \.self) { journey in
                        ZStack {
                            HStack {
                                Text(journey.place)
                                    .bold()
                                    .padding(.vertical, 15)
                                Spacer()
                                Text(DateManager.getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }
                            NavigationLink(destination: SeeJourneyView(journey: journey,
                                                                       uid: Auth.auth().currentUser?.uid ?? "",
                                                                       downloadMode: false,
                                                                       path: "\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(self.uid)/journeys")) {
                                EmptyView()
                            }
                                                                       .opacity(0)
                        }
                    }
                    .onDelete(perform: self.delete)
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.inset)
                .refreshable {
                    SentByYouManager(list: self.$sentByYou).populateYourJourneys(uid: self.uid) {
                        self.loadedYourJourneys = true
                    }
                }
                //Alert is shown if users want to delete any journey they sent.
                .alert(isPresented: self.$askAboutDeletion) {
                    Alert (title: Text(UIStrings.deleteJourney),
                           message: Text(UIStrings.sureToDelete),
                           primaryButton: .cancel(Text(UIStrings.cancel)) {
                        self.askAboutDeletion = false
                        self.journeyToDelete = SingleJourney()
                    },
                           secondaryButton: .destructive(Text(UIStrings.delete)) {
                        SentByYouManager(list: self.$sentByYou).deleteJourneyFromDatabase(name: self.journeyToDelete.name, uid: self.uid)
                        // TODO: - check for a completion
                        SentByYouManager(list: self.$sentByYou).checkForDuplicate(name: self.journeyToDelete.name, uid: self.uid) { lastCopy in
                            if lastCopy {
                                SentByYouManager(list: self.$sentByYou).deleteJourneyFromStorage(journey: self.journeyToDelete)
                            }
                            self.sentByYou.removeAll(where: {$0.name == self.journeyToDelete.name})
                            self.journeyToDelete = SingleJourney()
                        }
                    }
                    )
                }
            }
        }
        .fullScreenCover(isPresented: self.$sendJourneyScreen, onDismiss: {
            SentByYouManager(list: self.$sentByYou).populateYourJourneys(uid: self.uid) {
                self.loadedYourJourneys = true
            }
        }) {
            SendJourneyView(targetUID: self.uid)
        }
    }

    func delete(at offsets: IndexSet) {
        self.journeyToDelete = self.sentByYouFilteredSorted[offsets[offsets.startIndex]]
        self.askAboutDeletion = true
    }
}
