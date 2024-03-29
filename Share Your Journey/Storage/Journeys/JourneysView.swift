//
//  JourneysView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 11/04/2022.
//

import SwiftUI
import Firebase

struct JourneysView: View {
    
    //Variable's value justifies if program should show list of downloaded journeys or list of journeys pulled from the server.
    @State private var downloaded = false
    //Variable is supposed to contain all journeys that belong to the user.
    @State private var journeysList: [SingleJourney] = []
    //Variable is supposed to contain all journeys that user has downloaded before.
    @State private var downloadedJourneysList: [SingleJourney] = []
    //Variable is supposed to contain name of journey that needs to be deleted.
    @State private var journeyToDelete = SingleJourney()
    //Variable's value justifies if program should as user about deleting journey with alert.
    @State private var askAboutDeletion = false
    //Variable contains data entered by user to search through list of existing journeys.
    @State private var searchedJourney = ""
    //Variable is calculated by filtering list with user's journeys.
    @State private var loadedJourneys = false

    private var journeysFilteredList: [SingleJourney]  {
        if self.searchedJourney == "" {
            return self.journeysList
        } else {
            return self.journeysList.filter({return $0.place.lowercased().contains(self.searchedJourney.lowercased())})
        }
    }
    
    //Variable is calculated by filtering list with user's downloaded journeys.
    private var downloadedJourneysFilteredList: [SingleJourney]  {
        if self.searchedJourney == "" {
            return self.downloadedJourneysList
        } else {
            return self.downloadedJourneysList.filter({return $0.place.lowercased().contains(self.searchedJourney.lowercased())})
        }
    }
    
    var body: some View {
        VStack (spacing: 0) {
            PickerView(choice: self.$downloaded, firstChoice: UIStrings.saved, secondChoice: UIStrings.onDevice)
                .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
            
            SearchField(text: UIStrings.searchJourney, search: self.$searchedJourney)
            
            if self.downloaded {
                ListWithDownloadedJourneys(downloadedJourneysFilteredList: self.downloadedJourneysFilteredList,
                                           downloadedJourneysList: self.$downloadedJourneysList,
                                           journeyToDelete: self.$journeyToDelete,
                                           askAboutDeletion: self.$askAboutDeletion)
            } else {
                ListWithJourneys(journeysFilteredList: self.journeysFilteredList,
                                 journeysList: self.$journeysList,
                                 journeyToDelete: self.$journeyToDelete,
                                 askAboutDeletion: self.$askAboutDeletion,
                                 loadedJourneys: self.$loadedJourneys)
            }
        }
        .onAppear {
            JourneysManager(list: self.$journeysList).clearInvalidJourneys()
            JourneysManager(list: self.$journeysList).updateJourneys(completion: {
                self.loadedJourneys = true
            })
        }
    }
}
