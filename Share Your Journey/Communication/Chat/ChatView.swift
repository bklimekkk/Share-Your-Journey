//
//  ChatView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 14/02/2022.
//

import SwiftUI
import Firebase

//Struct is responsoble for showing users entire chat with their friends.
struct ChatView: View {
    //Variable's value controls if users can see journeys they sent to their friends or reversibly.
    @State private var yourJourneys = false
    
    //Variable's value controls if screen with functionality neccessary for sending journey should be presented.
    @State private var sendJourneyScreen = false
    
    //Variable controls if program should ask user about deleting particular item in the array.
    @State private var askAboutDeletion = false
    
    //Variable contains text entered by user in order to search items in the array.
    @State private var searchJourney = ""
    
    //Array is supposed to contain all journeys send by user.
    @State private var sentByYou: [SingleJourney] = []
    
    //Array containing journeys sent by friend.
    @State private var sentByFriend: [SingleJourney] = []
    
    //Variable contains all journeys send by users that they searched.
    private var sentByYouFiltered: [SingleJourney] {
        if searchJourney == "" {
            return sentByYou
        } else {
            return sentByYou.filter({return $0.name.lowercased().contains(searchJourney.lowercased())})
        }
    }
    
    //Variable contais all journeys searched by users.
    private var sentByFriendFiltered: [SingleJourney] {
        if searchJourney == "" {
            return sentByFriend
        } else {
            return sentByFriend.filter({return $0.name.lowercased().contains(searchJourney.lowercased())})
        }
    }
    
    //Friend's email adress.
    var email: String
    
    var body: some View {
        VStack {
            
            //Picker View controls which part of the screen is visible (array with your journeys or array with your friend's journeys).
            PickerView(choice: $yourJourneys, firstChoice: "Sent by \(email)", secondChoice: "Sent by you")
                .padding()
            
            //Field used to search arrays.
            SearchField(text: "Search journey", search: $searchJourney)
            
            if yourJourneys {
                YourJourneysList(searchJourney: $searchJourney, sendJourneyScreen: $sendJourneyScreen, askAboutDeletion: $askAboutDeletion, sentByYou: $sentByYou, email: email, sentByYouFiltered: sentByYouFiltered)
                
                Spacer()
                
                //Clicking this button opens screen enabling users to send selected journey.
                Button {
                    sendJourneyScreen.toggle()
                } label: {
                    ButtonView(buttonTitle: "Send journey")
                }
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            } else {
                FriendJourneysList(searchJourney: $searchJourney, sentByFriend: $sentByFriend, sentByFriendFiltered: sentByFriendFiltered, email: email)
            }
        }
        .navigationTitle(email)
        .navigationBarTitleDisplayMode(.inline)
    }
}
