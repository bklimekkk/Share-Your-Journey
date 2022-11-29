//
//  WeatherIconView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/08/2022.
//

import SwiftUI

struct WeatherIconView: View {
    var weatherArray: [Weather]
    var url: String
    var body: some View {
        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(self.weatherArray.isEmpty ? "" : self.weatherArray[0].icon)@4x.png")) { image in
            image
                .resizable()
                .scaledToFit()
                .frame(width: 60)
            
            
        }placeholder: {
            ZStack {
                VStack{}
                    .frame(width: 60, height: 40)
                ProgressView()
            }
            .padding(.bottom, 20)
        }
    }
}

