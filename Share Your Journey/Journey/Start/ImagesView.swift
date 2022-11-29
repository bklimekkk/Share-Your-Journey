//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/07/2022.
//

import SwiftUI
import MapKit

struct ImagesView: View {
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    var layout: [GridItem]
    var singleJourney: SingleJourney
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            PhotosAlbumView(showPicture: self.$showPicture,
                            photoIndex: self.$photoIndex,
                            highlightedPhoto: self.$highlightedPhoto,
                            layout: self.layout,
                            singleJourney: self.singleJourney)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button{
                        self.dismiss()
                    }label:{
                        Image(systemName: "chevron.compact.down")
                            .font(.system(size: 40))
                    }
                    .opacity(self.showPicture ? 0 : 1)
                    .disabled(self.showPicture ? true : false)
                }
            }
            .padding(.horizontal, 5)
            .navigationTitle("Current Journey Images")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
