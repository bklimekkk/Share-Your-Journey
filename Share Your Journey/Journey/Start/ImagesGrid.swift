//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/07/2022.
//

import SwiftUI
import MapKit

struct ImagesGrid: View {
    @EnvironmentObject var currentLocationManager: CurrentLocationManager
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    @Binding var photos: [SinglePhoto]

    var layout: [GridItem]
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
                            photos: self.$photos,
                            layout: self.layout)
            .environmentObject(self.currentLocationManager)
            .padding(.horizontal, 5)
        }

    }
}
