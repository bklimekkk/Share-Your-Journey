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
    //Array is supposed to contain all journeys send by user.
    @State private var sentByYou: [SingleJourney] = []
    //Array containing journeys sent by friend.
    @State private var sentByFriend: [SingleJourney] = []
    //Variable contains text entered by user in order to search items in the array.
    @State private var searchJourney = UIStrings.emptyString
   
    //Variable contains all journeys send by users that they searched.
    private var sentByYouFiltered: [SingleJourney] {
        if self.searchJourney == UIStrings.emptyString {
            return self.sentByYou
        } else {
            return self.sentByYou.filter({return $0.place.lowercased().contains(self.searchJourney.lowercased())})
        }
    }
    
    //Variable contais all journeys searched by users.
    private var sentByFriendFiltered: [SingleJourney] {
        if self.searchJourney == UIStrings.emptyString {
            return self.sentByFriend
        } else {
            return self.sentByFriend.filter({return $0.place.lowercased().contains(self.searchJourney.lowercased())})
        }
    }
    
    //Friend's email adress.
    var email: String
    
    var body: some View {
        VStack {
            
                //Picker View controls which part of the screen is visible (array with your journeys or array with your friend's journeys).
            PickerView(choice: self.$yourJourneys, firstChoice: UIStrings.sentByFriend, secondChoice: UIStrings.sentByYou)
                .padding(.vertical)
                .padding(.horizontal, 5)
                
                //Field used to search arrays.
            SearchField(text: UIStrings.searchJourney, search: self.$searchJourney)
            if self.yourJourneys {
                YourJourneysList(searchJourney: self.$searchJourney, sendJourneyScreen: self.$sendJourneyScreen, askAboutDeletion: self.$askAboutDeletion, sentByYou: self.$sentByYou, email: self.email, sentByYouFiltered: self.sentByYouFiltered)
                    
                    Spacer()
                    
                    //Clicking this button opens screen enabling users to send selected journey.
                    Button {
                        self.sendJourneyScreen.toggle()
                    } label: {
                        ButtonView(buttonTitle: UIStrings.sendJourney)
                    }
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                } else {
                    FriendJourneysList(searchJourney: self.$searchJourney, sentByFriend: self.$sentByFriend, sentByFriendFiltered: self.sentByFriendFiltered, email: self.email)
                }
        }
        .navigationTitle(self.email)
        .navigationBarTitleDisplayMode(.inline)
    }
}
