//
//  PhotosCounterView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/12/2022.
//

import SwiftUI
import MapKit

struct PhotosCounterView: View {
    var currentNumber: Int
    var overallNumber: Int
    @Binding var mapType: MKMapType
    var body: some View {
        Text("\(self.currentNumber)/\(self.overallNumber)")
            .foregroundColor(self.mapType == .standard ? .gray : .white)
            .bold()
            .font(.system(size: 40))
            .padding(.leading, 5)
    }
}
