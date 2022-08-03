//
//  WeatherModel.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/08/2022.
//

import Foundation

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let name: String
    let sys: Sys
}

struct Weather: Codable {
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let pressure: Double
    let humidity: Double
}

struct Wind: Codable {
    let speed: Double
}

struct Sys: Codable {
    let country: String
}




