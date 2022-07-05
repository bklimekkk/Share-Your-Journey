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
    var buttonColor: Color {
        colorScheme == .dark || mapType == .hybridFlyover ? .white : .accentColor
    }
    @Environment(\.colorScheme) var colorScheme
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
                    .foregroundColor(buttonColor)
            }
        }
        .padding(.vertical, 10)
        
        Button {
            walking = false
        } label : {
            if walking {
                Image(systemName: "car")
                    .font(.system(size: 30))
                    .foregroundColor(buttonColor)
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
    @Binding var showDeleteAlert: Bool
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
                showDeleteAlert = true
            } label: {
                ButtonView(buttonTitle: "Quit")
                    .background(.red)
            }
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
