//
//  PhotoView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 28/02/2022.
//

import SwiftUI

struct PhotoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var saved = false
    var photo: UIImage
    var photoNumber: Int
    var body: some View {
        VStack (spacing: 0) {
            Text(String(photoNumber + 1))
                .font(.system(size: 30))
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
            
            
            HStack {
                Button{
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    ButtonView(buttonTitle: "Back to journey")
                        .background(Color.blue)
                }
                
                if !saved {
                Button{
                    UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
                    saved = true
                } label: {
                    ButtonView(buttonTitle: "Save to camera roll")
                        .background(Color.purple)
                }
                } else {
                    Button{} label: {
                        ButtonView(buttonTitle: "Image already saved")
                            .background(Color.gray)
                    }
                    .disabled(true)
                }
            }
        }
    }
}
