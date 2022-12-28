//
//  PhotosCounterView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/12/2022.
//

import SwiftUI

struct PhotosCounterView: View {
    var number: Int
    var body: some View {
        Text(String(self.number))
            .foregroundColor(.gray)
            .bold()
            .font(.system(size: 40))
            .padding(.leading, 5)
    }
}

struct PhotosCounterView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosCounterView(number: 0)
    }
}
