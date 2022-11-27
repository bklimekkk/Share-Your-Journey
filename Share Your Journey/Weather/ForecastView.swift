//
//  ForecastView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/08/2022.
//

import SwiftUI

struct ForecastView: View {
    var forecastResponse: ForecastResponse
    var latitude: Double
    var longitude: Double
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(self.forecastResponse.list, id: \.self.dtTxt) { forecastEntity in
                    VStack(spacing: 0) {
                        Text(self.getDayOfWeekAndTime(dateAndTimeString: forecastEntity.dtTxt))
                    WeatherIconView(weatherArray: forecastEntity.weather, url: "")
                    Text("\(Int(forecastEntity.main.temp))°C")
                            .offset(y: -10)
                    }
                    .offset(y: 10)
                }
            }
            .padding(.horizontal, 7)
        }
    }
    
    func getDayOfWeekAndTime(dateAndTimeString: String) -> String {
        let daysOfTheWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: dateAndTimeString) else {return ""}
        
            let calendar = Calendar(identifier: .gregorian)
        let dayOfWeek = calendar.component(.weekday, from: date)
            let hour = calendar.component(.hour, from: date)
        
            return "\(daysOfTheWeek[dayOfWeek - 1]), \(hour):00"
        
    }
}

