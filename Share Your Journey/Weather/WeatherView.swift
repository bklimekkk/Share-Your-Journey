//
//  WeatherView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/08/2022.
//

import SwiftUI

struct WeatherView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var weatherResponse = WeatherResponse(weather: [], main: Main(temp: 0.0, pressure: 0.0, humidity: 0.0), wind: Wind(speed: 0.0), name: "", sys: Sys(country: ""))
    var latitude: Double
    var longitude: Double
    var body: some View {
        
        VStack {
            HStack {
                Text("\(weatherResponse.name)\(weatherResponse.name.isEmpty ? "" : ",") \(weatherResponse.sys.country)")
                    .font(.headline).bold()
                Spacer()
                Text("current")
            }
            
            
            HStack (alignment: .top) {
                VStack(spacing: 0) {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weatherResponse.weather.isEmpty ? "" : weatherResponse.weather[0].icon)@4x.png")) { image in
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
                    
                    Text("\(Int(weatherResponse.main.temp))°C")
                        .font(.subheadline).bold()
                }
                .padding(.top, 6)
                Spacer()
                
                VStack(spacing: 0) {
                    Image(systemName: "wind")
                        .foregroundColor(.gray)
                        .font(.system(size: 33))
                    Text("\(Int(weatherResponse.wind.speed))km/h")
                        .font(.subheadline).bold()
                        .padding(.top)
                }
                .padding(.top)
                .offset(x: -7)
                
                Spacer()
                
                VStack(spacing: 0) {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 30))
                    Text("\(Int(weatherResponse.main.humidity))%")
                        .font(.subheadline).bold()
                        .padding(.top)
                }
                .padding(.top)
                .offset(x: -7)
           
            }
        }
        .padding()
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 1)
        )
        
        
        .task {
            await WeatherRequest(weatherResponse: $weatherResponse, latitude: latitude, longitude: longitude).fetchWeatherData()
        }
    }
}

