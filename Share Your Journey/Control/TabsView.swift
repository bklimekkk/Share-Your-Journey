//
//  TabsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 12/02/2022.
//

import SwiftUI
import MapKit

struct TabsView: View {

    @ObservedObject var notificationSetup = NotificationSetup.shared
    @State private var selectedTab = 1
    var body: some View {

        //This view ensures that the application presents user with bottom navigation containing three elements.
        TabView (selection: self.$selectedTab) {
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
                    .environmentObject(self.notificationSetup)
            }
            .tabItem {
                Label(UIStrings.friendsTabTitle, systemImage: Icons.personFill)
            }
            .tag(3)
        }
        .onAppear {
            if self.notificationSetup.notificationType != .none {
                self.selectedTab = 3
            }
        }
        .onChange(of: self.notificationSetup.notificationType, perform: { newValue in
            self.selectedTab = 3
        })
        .onChange(of: self.selectedTab) { newValue in
            HapticFeedback.mediumHapticFeedback()
        }
    }
}
