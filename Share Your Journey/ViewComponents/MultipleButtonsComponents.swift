//
//  MultipleButtonsComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import SwiftUI
import MapKit

//Struct contains code responsible for generating icons allowing users to change the way how they receive directions to particular point (walking / driving).
struct DirectionIcons: View {
    @Binding var mapType: MKMapType
    @Binding var subscriber: Bool
    @Binding var showPanel: Bool
    var buttonColor: Color {
        colorScheme == .dark ? .white : .accentColor
    }
    var gold: Color {
        Color(uiColor: UIColor(red: 0.90, green: 0.42, blue: 0.00, alpha: 1.00))
    }
    @Environment(\.colorScheme) var colorScheme
    @Binding var walking: Bool
    var body: some View {
        
        //Chosen icon is set to green colour.
        Button{
            if subscriber {
                walking = true
            } else {
                showPanel = true
            }
        } label : {
            if walking {
                MapButton(imageName: "figure.walk")
                    .foregroundColor(Color.green)
            } else {
                 MapButton(imageName: "figure.walk")
                    .foregroundColor(subscriber ? buttonColor : gold)
            }
        }
        
        Button {
            walking = false
        } label : {
            if walking {
                MapButton(imageName: "car")
                    .foregroundColor(buttonColor)
            } else {
                MapButton(imageName: "car")
                    .foregroundColor(Color.green)
            }
        }
    }
}

//Struct contains code that generate buttons necessary for saving the journey and closing sum-up screen.
struct SumUpFunctionalityButtonsView: View {
    
    //Variables are described in SumUpView struct.
    @Binding var saveJourney: Bool
    @Binding var showDeleteAlert: Bool
    var body: some View {
        HStack {
            Button {
                showDeleteAlert = true
            } label: {
                ButtonView(buttonTitle: "Quit")
                    .background(.red)
            }
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            Button {
                saveJourney = true
            } label: {
                ButtonView(buttonTitle: "Save journey")
            }
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 5)
    }
}
