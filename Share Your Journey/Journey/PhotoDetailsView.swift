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
                PhotoDetailView(title: "Administrative Area", information: self.photo.administrativeArea)
                PhotoDetailView(title: "Country", information: self.photo.country)
                PhotoDetailView(title: "Country Code", information: self.photo.isoCountryCode)
                PhotoDetailView(title: "Name", information: self.photo.name)
                PhotoDetailView(title: "Postal Code", information: self.photo.postalCode)
                PhotoDetailView(title: "Ocean", information: self.photo.ocean)
                PhotoDetailView(title: "Inland Water", information: self.photo.inlandWater)
                PhotoDetailView(title: "AreasOfInterest", information: self.photo.areasOfInterest.joined(separator: ","))
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
        if !information.isEmpty {
            HStack {
                Text(self.title)
                Spacer()
                Text(self.information)
            }
        }
    }
}

struct PhotoDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailsView(photo: SinglePhoto())
    }
}
