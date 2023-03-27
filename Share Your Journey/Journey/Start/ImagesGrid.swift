//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/07/2022.
//

import SwiftUI
import MapKit

struct ImagesGrid: View {
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    var layout: [GridItem]
    var photos: [SinglePhoto]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        if self.showPicture {
            HighlightedPhoto(highlightedPhotoIndex: self.$photoIndex,
                             showPicture: self.$showPicture,
                             highlightedPhoto: self.$highlightedPhoto,
                             photos: self.photos)
        } else {
            PhotosAlbumView(showPicture: self.$showPicture,
                            photoIndex: self.$photoIndex,
                            highlightedPhoto: self.$highlightedPhoto,
                            layout: self.layout,
                            photos: self.photos)
            .padding(.horizontal, 5)
        }

    }
}
