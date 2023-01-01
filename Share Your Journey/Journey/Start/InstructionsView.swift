//
//  InstructionsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 07/07/2022.
//

import SwiftUI

struct InstructionsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var buttonColor: Color {
        self.colorScheme == .dark ? .white : .accentColor
    }

    var body: some View {
        NavigationView {
            Form {
                Group {
                    HStack {
                        SettingsButton()
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 7)
                        Text(UIStrings.viewingSettingOptions)
                    }
                    HStack {
                        Button {} label: {
                            SymbolButtonView(buttonImage: Icons.playFill)
                        }
                        .disabled(true)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 50)
                        Text(UIStrings.resumingTheJourney)
                    }
                    HStack {
                        Button {} label: {
                            SymbolButtonView(buttonImage: Icons.checkmark)
                        }
                        .disabled(true)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 50)
                        Text(UIStrings.finishingTheJourney)
                    }
                    
                    HStack {
                        Button {} label: {
                            SymbolButtonView(buttonImage: Icons.xmark)
                        }
                        .disabled(true)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 50)
                        Text(UIStrings.deletingTheJourney)
                    }
                    HStack {
                        MapTypeButton()
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 5)
                        
                        Text(UIStrings.switchingMapTypes)
                    }
                    HStack {
                        LocationButton()
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 5)
                        Text(UIStrings.recenteringTheMap)
                    }
                    HStack {
                        ImageButton()
                            .foregroundColor(self.buttonColor)
                        Text(UIStrings.viewingTakenPhotos)
                    }
                    HStack {
                        Image(systemName: Icons.figureWalk)
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 7)
                        Text(UIStrings.switchingToWalking)
                    }
                    HStack {
                        Image(systemName: Icons.car)
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                        
                        Text(UIStrings.switchingToDriving)
                    }
                    HStack{
                        Image(systemName: Icons.arrowBackwardCircleFill)
                            .foregroundColor(buttonColor)
                            .font(.system(size: 35))
                        Text(UIStrings.loggingOut)
                    }
                }
                Group {
                    HStack{
                        Image(systemName: Icons.plusAppFill)
                            .font(.system(size: 35))
                            .foregroundColor(self.buttonColor)
                        Text(UIStrings.uploadingImage)
                    }
                    HStack {
                        Image(systemName: Icons.cameraFill)
                            .font(.system(size: 27))
                            .foregroundColor(self.buttonColor)
                        Text(UIStrings.takingAPicture)
                    }
                    HStack {
                        SymbolButtonView(buttonImage: Icons.pauseFill)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: 40)
                        Text(UIStrings.allowsToPause)
                    }
                    HStack {
                        Image(systemName: Icons.squareAndArrowDown)
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 3)
                        Text(UIStrings.downloadingToDevice)
                    }
                    HStack {
                        Image(systemName: Icons.plus)
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 4)
                        Text(UIStrings.allowsToMoveDownloaded)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        self.dismiss()
                    }label: {
                       SheetDismissButtonView()
                    }
                }
            }
            .navigationTitle(UIStrings.instructions)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
