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
        guard let url = URL(string: "\(Links.openWeatherEndpoint)forecast?lat=\(self.latitude)&lon=\(self.longitude)&units=metric&appid=\(Links.openWeatherAPIKey)") else {
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
