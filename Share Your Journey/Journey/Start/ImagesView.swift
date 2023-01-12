//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 11/01/2023.
//

import Foundation
import SwiftUI

struct ImagesView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    @Binding var takeAPhoto: Bool
    var numberOfPhotos: Int
    var layout: [GridItem]
    var singleJourney: SingleJourney

    var body: some View {
        if self.numberOfPhotos == 0 {
            NavigationView {
                VStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Text("The journey is empty")
                        if self.takeAPhoto {
                            ProgressView()
                        } else {
                            Button("Take a photo") {
                                self.takeAPhoto = true
                                self.dismiss()
                            }
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button{
                            self.dismiss()
                        }label:{
                            SheetDismissButtonView()
                        }
                    }
                }
            }
        } else {
            ZStack {
                ImagesGrid(showPicture: self.$showPicture,
                           photoIndex: self.$photoIndex,
                           highlightedPhoto: self.$highlightedPhoto,
                           layout: self.layout,
                           singleJourney: self.singleJourney)
                HighlightedPhoto(highlightedPhotoIndex: self.$photoIndex,
                                 showPicture: self.$showPicture,
                                 highlightedPhoto: self.$highlightedPhoto,
                                 journey: self.singleJourney)
            }
        }
    }
}
