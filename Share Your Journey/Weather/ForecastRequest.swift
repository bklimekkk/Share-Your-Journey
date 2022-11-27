//
//  ForecastRequest.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/08/2022.
//

import Foundation
import SwiftUI

struct ForecastRequest {
    @Binding var forecastResponse: ForecastResponse
    var latitude: Double
    var longitude: Double
    
    func fetchForecastData() async {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(self.latitude)&lon=\(self.longitude)&units=metric&appid=de4cd596a3675b54b7984438a796ad56") else {
            print("Invalid url")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let decodedData = try? decoder.decode(ForecastResponse.self, from: data) {
                self.forecastResponse = decodedData
            }
        } catch {
            print("Invalid data")
        }
    }
}
