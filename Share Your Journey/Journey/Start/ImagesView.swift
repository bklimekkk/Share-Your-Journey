//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 11/01/2023.
//

import Foundation
import SwiftUI

struct ImagesView: View {
    @Binding var showPicture: Bool
    @Binding var photoIndex: Int
    @Binding var highlightedPhoto: UIImage
    var layout: [GridItem]
    var singleJourney: SingleJourney

    var body: some View {
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
