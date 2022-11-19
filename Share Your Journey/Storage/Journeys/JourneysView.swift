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
    @State private var journeyToDelete = ""
    
    //Variable's value justifies if program should as user about deleting journey with alert.
    @State private var askAboutDeletion = false
    
    //Variable contains data entered by user to search through list of existing journeys.
    @State private var searchedJourney = ""
    
    //Variable's value justifies if deleted journey should be deleted from storage as well (if it doesn't exist anywhere else in the system.
    @State private var deleteFromStorage = true
    
    //Variable is calculated by filtering list with user's journeys.
    private var journeysFilteredList: [SingleJourney]  {
        if searchedJourney == "" {
            return journeysList
        } else {
            return journeysList.filter({return $0.name.lowercased().contains(searchedJourney.lowercased())})
        }
    }
    
    //Variable is calculated by filtering list with user's downloaded journeys.
    private var downloadedJourneysFilteredList: [SingleJourney]  {
        if searchedJourney == "" {
            return downloadedJourneysList
        } else {
            return downloadedJourneysList.filter({return $0.name.lowercased().contains(searchedJourney.lowercased())})
        }
    }
    
    var body: some View {
        

        VStack {
            PickerView(choice: $downloaded, firstChoice: "Saved", secondChoice: "Downloaded")
                .padding()
            
            SearchField(text: "Search journey", search: $searchedJourney)
            
            if downloaded {
                ListWithDownloadedJourneys(downloadedJourneysFilteredList: downloadedJourneysFilteredList, downloadedJourneysList: $downloadedJourneysList, journeyToDelete: $journeyToDelete, askAboutDeletion: $askAboutDeletion)
            } else {
                ListWithJourneys(journeysFilteredList: journeysFilteredList, journeysList: $journeysList, journeyToDelete: $journeyToDelete, deleteFromStorage: $deleteFromStorage, askAboutDeletion: $askAboutDeletion)
            }
        }
        
    }
}
