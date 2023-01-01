//
//  WeatherRequest.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/08/2022.
//

import Foundation
import SwiftUI

struct WeatherRequest {
    @Binding var weatherResponse: WeatherResponse
    var latitude: Double
    var longitude: Double
    
    func fetchWeatherData() async {
        guard let url = URL(string: "\(Links.openWeatherEndpoint)weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(Links.openWeatherAPIKey)") else {
            print("Invalid url")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let decodedData = try? decoder.decode(WeatherResponse.self, from: data) {
                self.weatherResponse = decodedData
            }
        } catch {
            print("Invalid data")
        }
    }
}
