//
//  TabsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 12/02/2022.
//

import SwiftUI
import MapKit

struct TabsView: View {
    @State private var journeysList: [SingleJourney] = []
    //Default view is always set to StartView (the one containing a map.
    init() {
        UITabBar.appearance().backgroundColor = Colors.tabViewColor
    }
    var body: some View {

        //This view ensures that the application presents user with bottom navigation containing three elements.
        TabView () {
            StartView()
                .tabItem {
                    Label(UIStrings.yourJourneyTabTitle, systemImage: Icons.mapFill)
                }
                .tag(1)
                .navigationTitle(UIStrings.emptyString)
                .navigationBarHidden(true)

            NavigationView {
                JourneysView()
                    .navigationTitle(UIStrings.emptyString)
                    .navigationBarHidden(true)
            }
            .tabItem {
                Label(UIStrings.journeysTabTitle, systemImage: Icons.mappin)
            }
            .tag(2)
            
            NavigationView {
                FriendsView()
                    .navigationTitle(UIStrings.emptyString)
                    .navigationBarHidden(true)
            }
            .tabItem {
                Label(UIStrings.friendsTabTitle, systemImage: Icons.personFill)
            }
            .tag(3)
        }
    }
}
