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
      
        NavigationView {
            //This view ensures that the application presents user with bottom navigation containing three elements.
            TabView () {
                StartView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .tag(1)
                
                
                JourneysView()
                    .tabItem {
                        Label("Journeys", systemImage: "mappin")
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .tag(2)
                
                FriendsView()
                    .tabItem {
                        Label("Friends", systemImage: "person.fill")
                    }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .tag(3)
            }
        }
    }
}
