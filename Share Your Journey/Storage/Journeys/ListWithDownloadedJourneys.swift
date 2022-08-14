//
//  ListWithDownloadedJourneys.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import SwiftUI
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
    @Binding var askAboutDeletion: Bool
    @Binding var journeyToDelete: String
    
    var body: some View {
        VStack {
            if downloadedJourneysFilteredList.isEmpty{
                NoDataView(text: "No journeys to show. Tap to refresh.")
                    .onTapGesture {
                        populateWithDownloadedJourneys()
                    }
            } else {
                List (downloadedJourneysFilteredList.sorted(by: {$0.date > $1.date}), id: \.self) { journey in
                    NavigationLink(destination: SeeJourneyView(journey: journey, email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "", downloadMode: true, path: "")) {
                        HStack {
                            Button{
                                askAboutDeletion = true
                                journeyToDelete = journey.name
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 10)
                            Text(journey.name)
                                .padding(.vertical, 15)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.inset)
                
                .alert(isPresented: $askAboutDeletion) {
                    //After tapping "x" button, users are always asked if they are sure to delete this particular journey.
                    Alert (title: Text("Delete journey"),
                           message: Text("Are you sure that you want to delete this journey?"),
                           primaryButton: .cancel(Text("Cancel")) {
                        askAboutDeletion = false
                        journeyToDelete = ""
                    },
                           secondaryButton: .destructive(Text("Delete")) {
                        deleteDownloadedJourney()
                    }
                    )
                }
            }
        }
        .onAppear {
            populateWithDownloadedJourneys()
        }
        .refreshable {
            populateWithDownloadedJourneys()
        }
    }
    
    /**
     Function is responsible for adding journeys that user has downloaded previously to the appropriate array.
     */
    func populateWithDownloadedJourneys() {
        
        //Function checks which user is currently logged in. If new user has logged into the application, program clears the array.
        if downloadedJourneysList.count > 0 && downloadedJourneysList[0].email != FirebaseSetup.firebaseInstance.auth.currentUser?.email {
            downloadedJourneysList = []
        }
        
        for i in journeys.filter({return $0.email == FirebaseSetup.firebaseInstance.auth.currentUser?.email}) {
            if !downloadedJourneysList.map({return $0.name}).contains(i.name) {
                downloadedJourneysList.append(SingleJourney(email: FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "", name: i.name ?? "", date: i.date ?? Date(), numberOfPhotos: i.photosNumber as! Int, photos: [], photosLocations: [], networkProblem: i.networkProblem))
            }
        }
    }
    
    /**
     Function is responsible for deleting journey that user downloaded previously.
     */
    func deleteDownloadedJourney() {
        for i in 0...journeys.count - 1 {
            if journeys[i].name == journeyToDelete {
                moc.delete(journeys[i])
                break
            }
        }
        do {
            try moc.save()
        } catch {}
        
        //Journey has to be deleted from the array right away.
        for i in 0...downloadedJourneysList.count - 1 {
            if downloadedJourneysList[i].name == journeyToDelete {
                downloadedJourneysList.remove(at: i)
                break
            }
        }
        
        askAboutDeletion = false
        journeyToDelete = ""
    }
}
