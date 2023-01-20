//
//  ButtonComponents.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/04/2022.
//

import Foundation
import SwiftUI

//Struct generating button in the entire application.
struct ButtonView: View {
    var buttonTitle: String
    var body: some View {
        HStack{
            Spacer()
            Text(self.buttonTitle)
                .padding(.vertical, 10)
            Spacer()
        }
        .foregroundColor(Color.white)
    }
}

//Four buttons responsible for pausing, re-starting, finishing and quiting journey are generated by this struct.
struct SymbolButtonView: View {
    var buttonImage: String
    var body: some View {
        HStack{
            Spacer()
            Image(systemName: self.buttonImage)
                .foregroundColor(.white)
                .padding(.vertical, 11)
            Spacer()
        }
        .foregroundColor(Color.white)
    }
}

//Struct generating standard map type button used to change type of map.
struct LocationButton: View {
    var body: some View {
        MapButton(imageName: Icons.locationFill)
    }
}

//Struct generating standard map type button used to center the the map on user's location.
struct MapTypeButton: View {
    var body: some View {
        MapButton(imageName: Icons.map)
    }
}

struct ImageButton: View {
    var body: some View {
        MapButton(imageName: Icons.photoFillOnRectangleFill)
    }
}

//Struct contains code responsible for generating button allowing users to download all journey's photos.
struct DownloadGalleryButton: View {
    
    //Variables described in SeeJourneyView struct.
    var journey: SingleJourney
    @Binding var showDownloadAlert: Bool
    @Binding var showPicture: Bool
    
    var gold: Color {
        Color(uiColor: Colors.premiumColor)
    }
    
    var body: some View {
        Button{
            self.showDownloadAlert = true
        } label: {
            ButtonView(buttonTitle: UIStrings.saveAllImagesToCameraRoll)
        }
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 5)
        .padding(.top, 5)
        .disabled(self.journey.photos.map ({return $0.photo}).contains(UIImage()) ? true : false)
        .opacity(self.showPicture ? 0 : 1)
    }
}

struct MapButton: View {
    let imageName: String
    var load: Bool
    init(imageName: String, load: Bool) {
        self.imageName = imageName
        self.load = load
    }
    init(imageName: String) {
        self.imageName = imageName
        self.load = false
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThickMaterial)
                .frame(width: 40, height: 40)
            if self.load {
                ProgressView()
                    .padding(.leading, 5)
                    .offset(x: -2.5)
            } else {
                Image(systemName: self.imageName)
                    .font(.system(size: 20))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 1)
        )
    }
}

struct MapTextButton: View {
    let imageName: String
    let text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThickMaterial)
                .frame(width: 120, height: 40)
            HStack {
                Image(systemName: self.imageName)
                    .font(.system(size: 20))
                Text(text)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 1)
        )
    }
}




