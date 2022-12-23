//
//  PhotosCounterView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/12/2022.
//

import SwiftUI

struct PhotosCounterView: View {
    var numberOfPhotos: Int
    var body: some View {
        Text(String(numberOfPhotos))
            .foregroundColor(.gray)
            .bold()
            .font(.system(size: 40))
            .padding(.leading, 5)
    }
}

struct PhotosCounterView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosCounterView(numberOfPhotos: 0)
    }
}
