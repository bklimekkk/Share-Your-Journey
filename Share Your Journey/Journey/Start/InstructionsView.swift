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
                        Text("Viewing settings options.")
                    }
                    
                    HStack {
                        Button {} label: {
                            SymbolButtonView(buttonImage: "play.fill")
                        }
                        .disabled(true)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 50)
                        Text("Resuming the journey that was paused.")
                    }
                    
                    HStack {
                        Button {} label: {
                            SymbolButtonView(buttonImage: "checkmark")
                        }
                        .disabled(true)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 50)
                        Text("Finishing the journey.")
                    }
                    
                    HStack {
                        Button {} label: {
                            SymbolButtonView(buttonImage: "xmark")
                        }
                        .disabled(true)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 50)
                        Text("Deleting the journey.")
                    }
                    HStack {
                        MapTypeButton()
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 5)
                        
                        Text("Switching map types.")
                    }
                    
                    HStack {
                        LocationButton()
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 5)
                        
                        
                        Text("Re-centering the map on user's location.")
                    }
                    
                    HStack {
                        ImageButton()
                            .foregroundColor(self.buttonColor)
                        Text("Viewing photos that have already been taken.")
                    }
                    
                    HStack {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 7)
                        Text("Switching directions options to walking directions.")
                    }
                    HStack {
                        Image(systemName: "car")
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                        
                        Text("Switching directions options to driving directions.")
                    }
                    HStack{
                        Image(systemName: "arrow.backward.circle.fill")
                            .foregroundColor(buttonColor)
                            .font(.system(size: 35))
                        Text("Logging out from the their account.")
                    }
                }
                
                Group {
                    HStack{
                        Image(systemName: "plus.app.fill")
                            .font(.system(size: 35))
                            .foregroundColor(self.buttonColor)
                        Text("Uploading image from user's camera roll.")
                    }
                    
                    
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 27))
                            .foregroundColor(self.buttonColor)
                        Text("Taking a picture during the journey.")
                    }
                    
                    HStack {
                        SymbolButtonView(buttonImage: "pause.fill")
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 40)
                        Text("Allows to pause the journey.")
                    }
                    
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 3)
                        Text("Downloading the journey to device.")
                    }
                    
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                            .foregroundColor(self.buttonColor)
                            .padding(.horizontal, 4)
                        Text("Allows users to move downloaded journey to the list of saved journeys.")
                    }
                 
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Back to app") {
                        self.dismiss()
                    }
                }
            }
            .navigationTitle("Instructions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
