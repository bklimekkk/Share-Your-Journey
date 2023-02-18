//
//  ListWithDownloadedJourneys.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
import Firebase
import FirebaseStorage

//Struct contains code responsible for generating list with journeys downloaded by user.
struct ListWithDownloadedJourneys: View {
    var downloadedJourneysFilteredList: [SingleJourney]
    //Similar variable was described in SeeJourneyView struct.
    @FetchRequest(entity: Journey.entity(), sortDescriptors: [], predicate: nil, animation: nil) var journeys: FetchedResults<Journey>
    //Variable is used to save changes made to journeys collection in Core Data.
    @Environment(\.managedObjectContext) var moc
    //Variables are described in JourneysView struct.
    @Binding var downloadedJourneysList: [SingleJourney]
    var sortedDownloadedJourneysFilteredList: [SingleJourney] {
        return self.downloadedJourneysFilteredList.sorted(by: {$0.operationDate > $1.operationDate})
    }
    @Binding var journeyToDelete: SingleJourney
    @Binding var askAboutDeletion: Bool
    
    var body: some View {
        VStack {
            if self.downloadedJourneysFilteredList.isEmpty {
                NoDataView(text: UIStrings.noJourneysToShow)
                    .onTapGesture {
                        self.populateWithDownloadedJourneys()
                    }
            } else {
                List  {
                    ForEach (self.sortedDownloadedJourneysFilteredList, id: \.self) { journey in
                        ZStack {
                            HStack {
                                Text(journey.place)
                                    .bold()
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 15)
                                Spacer()
                                Text(DateManager.getDate(date: journey.date))
                                    .foregroundColor(.gray)
                            }
                            NavigationLink (destination: SeeJourneyView(journey: journey,
                                                                        uid: Auth.auth().currentUser?.uid ?? "",
                                                                        downloadMode: true,
                                                                        path: "")) {
                                EmptyView()
                            }
                                                                        .opacity(0)
                        }
                    }
                    .onDelete(perform: self.delete)
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.plain)
                .alert(isPresented: self.$askAboutDeletion) {
                    //After tapping "x" button, users are always asked if they are sure to delete this particular journey.
                    Alert (title: Text(UIStrings.deleteJourney),
                           message: Text(UIStrings.sureToDelete),
                           primaryButton: .cancel(Text(UIStrings.cancel)) {
                        self.askAboutDeletion = false
                        self.journeyToDelete = SingleJourney()
                    },
                           secondaryButton: .destructive(Text(UIStrings.delete)) {
                        self.deleteDownloadedJourney()
                    }
                    )
                }
            }
        }
        .onAppear {
            self.populateWithDownloadedJourneys()
        }
        .refreshable {
            self.populateWithDownloadedJourneys()
        }
    }
    
    /**
     Function is responsible for adding journeys that user has downloaded previously to the appropriate array.
     */
    func populateWithDownloadedJourneys() {
        
        //Function checks which user is currently logged in. If new user has logged into the application, program clears the array.
        if self.downloadedJourneysList.count > 0 && self.downloadedJourneysList[0].uid != Auth.auth().currentUser?.uid {
            self.downloadedJourneysList = []
        }

        self.journeys.filter({return $0.uid == Auth.auth().currentUser?.uid}).forEach { journey in
            if !self.downloadedJourneysList.map({return $0.name}).contains(journey.name) {
                self.downloadedJourneysList.append(SingleJourney(uid: Auth.auth().currentUser?.uid ?? "",
                                                                 name: journey.name ?? "",
                                                                 place: journey.place ?? "",
                                                                 date: journey.date ?? Date(),
                                                                 numberOfPhotos: journey.photosNumber as? Int ?? IntConstants.defaultValue,
                                                                 photos: [],
                                                                 photosLocations: []))
            }
        }
    }

    /**
     Function is responsible for deleting journey that user downloaded previously.
     */
    func deleteDownloadedJourney() {
        self.moc.delete(self.journeys.first(where: {$0.name == self.journeyToDelete.name}) ?? Journey())
        do {
            try moc.save()
        } catch {}
        self.downloadedJourneysList.removeAll(where: {$0.name == self.journeyToDelete.name})
        self.askAboutDeletion = false
        self.journeyToDelete = SingleJourney()
    }

    func delete(at offsets: IndexSet) {
        self.journeyToDelete = self.sortedDownloadedJourneysFilteredList[offsets[offsets.startIndex]]
        self.askAboutDeletion = true
    }
}
