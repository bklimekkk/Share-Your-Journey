//
//  PickerComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import SwiftUI

//Struct generating a picker, allowing users to choose between two options.
struct PickerView: View {
    var choice: Binding<Bool>
    var firstChoice: String
    var secondChoice: String
    var body: some View {
        Picker(selection: choice, label: Text("")) {
            Text(firstChoice)
                .tag(false)
            Text(secondChoice)
                .tag(true)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

//Struct is responsible for generating picker view allowing users to pick between three options.
struct JourneyPickerView: View {
    
    //This variable's value is set to one of three cases of ViewType enum.
    var choice: Binding<SeeJourneyView.ViewType>
    
    var firstChoice: String
    var secondChoice: String
    
    var body: some View {
        Picker(selection: choice, label: Text("")) {
            Text(firstChoice)
                .tag(SeeJourneyView.ViewType.threeDimensional)
            Text(secondChoice)
                .tag(SeeJourneyView.ViewType.photoAlbum)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
