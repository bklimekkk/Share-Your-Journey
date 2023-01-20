//
//  RemoveRouteView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 18/01/2023.
//

import SwiftUI

struct RemoveRouteView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var routeIsDisplayed: Bool
    var currentLocationManager: CurrentLocationManager
    var body: some View {
        Button{
            self.currentLocationManager.mapView.removeOverlays(self.currentLocationManager.mapView.overlays)
            self.routeIsDisplayed = false
        } label:{
            MapButton(imageName: Icons.xmarkSquareFill)
                .foregroundColor(self.colorScheme == .light ? Color.blue : .white)
        }

    }
}
