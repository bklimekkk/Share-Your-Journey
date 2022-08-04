//
//  ForecastModel.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/08/2022.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastList]
}

struct ForecastList: Codable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let dtTxt: String
}


