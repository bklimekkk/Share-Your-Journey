//
//  ShowPhotoDetailsView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 26/11/2022.
//

import SwiftUI

struct PhotoDetailsView: View {
    var photo: SinglePhoto
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            List {
                PhotoDetailView(title: "Location", information: self.photo.location)
                PhotoDetailView(title: "Sublocation", information: self.photo.subLocation)
            }
            .listStyle(.plain)
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        self.dismiss()
                    } label: {
                        Image(systemName: "chevron.compact.down")
                            .font(.system(size: 40))
                    }
                }
            }
        }
    }
}

struct PhotoDetailView: View {
    var title: String
    var information: String
    var body: some View {
        HStack {
            Text(self.title)
            Spacer()
            Text(self.information)
        }
    }
}

struct PhotoDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailsView(photo: SinglePhoto())
    }
}
