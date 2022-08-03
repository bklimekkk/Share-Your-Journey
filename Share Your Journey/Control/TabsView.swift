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
        UITabBar.appearance().backgroundColor = UIColor(named: "TabViewColor")
    }
    var body: some View {

            //This view ensures that the application presents user with bottom navigation containing three elements.
            TabView () {
                StartView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(1)
                    .navigationTitle("")
                    .navigationBarHidden(true)
                
                NavigationView {
                JourneysView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
                    .tabItem {
                        Label("Journeys", systemImage: "mappin")
                    }
                    .tag(2)
            
                NavigationView {
                FriendsView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
                    .tabItem {
                        Label("Friends", systemImage: "person.fill")
                    }
                    .tag(3)
                   
            }
    }
}
