//
//  PhotosCounterView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 24/12/2022.
//

import SwiftUI

struct PhotosCounterView: View {
    var currentNumber: Int
    var overallNumber: Int
    var body: some View {
        Text("\(self.currentNumber)/\(self.overallNumber)")
            .foregroundColor(.gray)
            .bold()
            .font(.system(size: 40))
            .padding(.leading, 5)
    }
}
