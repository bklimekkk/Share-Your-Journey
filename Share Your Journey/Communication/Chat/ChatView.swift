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
    @EnvironmentObject var notificationSetup: NotificationSetup
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
    @State private var searchJourney = ""
    @State private var loadedYourJourneys = false
    @State private var loadedFriendsJourneys = false
    //Friend's uid and nickname.
    var uid: String
    var nickname: String

    var body: some View {
        VStack (spacing: 0) {
            
            //Picker View controls which part of the screen is visible (array with your journeys or array with your friend's journeys).
            PickerView(choice: self.$yourJourneys, firstChoice: UIStrings.sentByFriend, secondChoice: UIStrings.sentByYou)
                .padding(.top, 5)
                .padding(.bottom, 15)
                .padding(.horizontal, 5)

            //Field used to search arrays.
            SearchField(text: UIStrings.searchJourney, search: self.$searchJourney)
            if self.yourJourneys {
                YourJourneysList(searchJourney: self.$searchJourney,
                                 sendJourneyScreen: self.$sendJourneyScreen,
                                 askAboutDeletion: self.$askAboutDeletion,
                                 sentByYou: self.$sentByYou,
                                 loadedYourJourneys: self.$loadedYourJourneys,
                                 uid: self.uid)
                Divider()
                Spacer()
                //Clicking this button opens screen enabling users to send selected journey.
                Button {
                    self.sendJourneyScreen.toggle()
                } label: {
                    ButtonView(buttonTitle: UIStrings.sendJourney)
                }
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
            } else {
                FriendJourneysList(searchJourney: self.$searchJourney,
                                   sentByFriend: self.$sentByFriend,
                                   loadedFriendsJourneys: self.$loadedFriendsJourneys,
                                   uid: self.uid)
                .environmentObject(self.notificationSetup)
            }
        }
        .onAppear {
            SentByYouManager(list: self.$sentByYou).populateYourJourneys(uid: self.uid) {
                self.loadedYourJourneys = true
            }
            SentByFriendManager(list: self.$sentByFriend).populateFriendsJourneys(uid: self.uid) {
                self.loadedFriendsJourneys = true
            }
            self.notificationSetup.notificationType = .none
            self.notificationSetup.sender = ""
        }
        .navigationTitle(self.nickname)
        .navigationBarTitleDisplayMode(.inline)
    }
}
