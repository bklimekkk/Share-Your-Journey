//
//  MultipleButtonsComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import SwiftUI

//Structs contains code that generate buttons necessarey for recentering and chnging map's type.
struct MapButtonsView: View {
    var currentLocationManager: CurrentLocationManager
    var body: some View {
        Button {
            currentLocationManager.changeTypeOfMap()
        } label: {
            if currentLocationManager.mapView.mapType == .standard {
                StandardLocationButton(locationManager: currentLocationManager)
            } else {
                HybridLocationButton(locationManager: currentLocationManager)
            }
        }
        .padding(.vertical, 10)
        
        
        Button {
            currentLocationManager.recenterLocation()
        } label: {
            if currentLocationManager.mapView.mapType == .standard {
                StandardMapTypeButton(locationManager: currentLocationManager)
            } else {
                HybridMapTypeButton(locationManager: currentLocationManager)
            }
        }
        .padding(.vertical, 10)
    }
}

//Struct contains code responsible for generating icons allowing users to change the way how they receive directions to particular point (walking / driving).
struct DirectionIcons: View {
    @Binding var walking: Bool
    var body: some View {
        
        //Chosen icon is set to green colour.
        Button{
            walking = true
        } label : {
            if walking {
                Image(systemName: "figure.walk")
                    .font(.system(size: 30))
                    .foregroundColor(Color.green)
            } else {
                Image(systemName: "figure.walk")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 10)
        
        Button {
            walking = false
        } label : {
            if walking {
                Image(systemName: "car")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "car")
                    .font(.system(size: 30))
                    .foregroundColor(Color.green)
            }
        }
        .padding(.vertical, 10)
    }
}

//Struct contains code that generate buttons necessary for saving the journey and closing sum-up screen.
struct SumUpFunctionalityButtonsView: View {
    
    //Variables are described in SumUpView struct.
    @Binding var saveJourney: Bool
    var sumUpPresented: () -> ()
    var body: some View {
        HStack {
            Button {
                saveJourney = true
            } label: {
                ButtonView(buttonTitle: "Save journey")
            }
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            Button {
                sumUpPresented()
            } label: {
                ButtonView(buttonTitle: "Quit")
            }
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
