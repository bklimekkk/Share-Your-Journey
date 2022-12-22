//
//  WeatherView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/08/2022.
//

import SwiftUI

struct WeatherView: View {

    @Environment(\.colorScheme) var colorScheme
    @State private var weatherResponse = WeatherResponse(weather: [], main: Main(temp: 0.0,
                                                                                 pressure: 0.0,
                                                                                 humidity: 0.0),
                                                         wind: Wind(speed: 0.0))
    @State private var forecastResponse = ForecastResponse(list: [])
    var latitude: Double
    var longitude: Double
    @State private var currentWeatherInformation = "current"
    var currentOrForecast = ["current", "forecast"]
    var body: some View {
        VStack {
            HStack {
                Text("\(self.weatherResponse.name)\(self.weatherResponse.name.isEmpty ? "" : ",") \(self.weatherResponse.sys.country)")
                    .font(.headline).bold()
                Spacer()
                Picker("current", selection: self.$currentWeatherInformation) {
                    ForEach(self.currentOrForecast, id: \.self) { service in
                        Text(service)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 7)
            if self.currentWeatherInformation == "current" {
                CurrentWeatherView(weatherResponse: self.weatherResponse)
            } else {
                ForecastView(forecastResponse: self.forecastResponse, latitude: self.latitude, longitude: self.longitude)
            }
        }
        .padding(.vertical, 7)
        .background(
//            colorScheme == .light ? Color(red: 0.81, green: 0.93, blue: 0.99) : Color(red: 0.00, green: 0.20, blue: 0.30),
//            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 0.5)
        )
        .task {
            await WeatherRequest(weatherResponse: self.$weatherResponse, latitude: self.latitude, longitude: self.longitude).fetchWeatherData()
            await ForecastRequest(forecastResponse: self.$forecastResponse, latitude: self.latitude, longitude: self.longitude).fetchForecastData()
        }
    }
}

struct CurrentWeatherView: View {
    var weatherResponse: WeatherResponse
    var body: some View {
        HStack (alignment: .top) {
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(self.weatherResponse.weather.isEmpty ? "" : self.weatherResponse.weather[0].icon)@4x.png")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75)
                } placeholder: {
                    ZStack {
                        VStack{}
                            .frame(width: 75, height: 55)
                        ProgressView()
                    }
                    .padding(.bottom, 20)
                }
                Text("\(Int(self.weatherResponse.main.temp))°C")
                    .font(.headline).bold()
            }
            .padding(.top, 6)
            Spacer()
            VStack(spacing: 0) {
                Image(systemName: "wind")
                    .foregroundColor(.gray)
                    .font(.system(size: 41))
                Text("\(Int(self.weatherResponse.wind.speed))km/h")
                    .font(.headline).bold()
                    .padding(.top)
            }
            .padding(.top)
            .offset(x: -15, y: 7)
            Spacer()
            VStack(spacing: 0) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 38))
                Text("\(Int(self.weatherResponse.main.humidity))%")
                    .font(.headline).bold()
                    .padding(.top)
            }
            .padding(.top)
            .offset(x: -10, y: 6)
       }
        .padding(.horizontal, 7)
    }
}

