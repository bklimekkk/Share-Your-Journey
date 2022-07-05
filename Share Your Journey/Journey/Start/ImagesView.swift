//
//  ImagesView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 04/07/2022.
//

import SwiftUI
import MapKit

struct ImagesView: View {
    @Binding var images: [SinglePhoto]
    @Binding var imagesLocations: [CLLocationCoordinate2D]
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(images, id: \.number) { image in
                            Image(uiImage: image.photo)
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius:10))
                                .shadow(color: .gray, radius: 2)
                                .scaledToFill()
                                .padding(.vertical, 5)
                                .padding(.horizontal, 1)
                        }
                }
                .padding()
                .navigationTitle("Journey Photos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Back to journey") {
                            dismiss()
                        }
                    }
            }
            }
        }
    }
}
