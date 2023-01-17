//
//  DirectionsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 17/01/2023.
//

import SwiftUI
import MapKit

struct DirectionsView: View {
    @Environment(\.colorScheme) var colorScheme
    var location: CLLocationCoordinate2D
    var body: some View {
        HStack {
                Button{
                    UIApplication.shared.open(URL(string: "http://maps.apple.com/?saddr=&daddr=\(self.location.latitude),\(self.location.longitude)&dirflg=d")!)
                }label: {
                    MapTextButton(imageName: Icons.locationNorthCircleFill, text: UIStrings.apple)
                        .foregroundColor(self.colorScheme == .light ? .accentColor : .white)
                }
                Button{
                    UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(self.location.latitude),\(self.location.longitude)&directionsmode=driving")!)
                }label: {
                    MapTextButton(imageName: Icons.locationNorthCircleFill, text: UIStrings.google)
                        .foregroundColor(self.colorScheme == .light ? .accentColor : .white)
                }
        }
    }
}

