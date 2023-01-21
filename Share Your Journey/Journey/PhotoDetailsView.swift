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
                Section {
                    PhotoDetailView(title: UIStrings.date, information: self.getDateString(date: self.photo.date))
                    PhotoDetailView(title: UIStrings.time, information: self.getTimeString(date: self.photo.date))
                    PhotoDetailView(title: UIStrings.location, information: self.photo.location)
                    PhotoDetailView(title: UIStrings.subLocation, information: self.photo.subLocation)
                    PhotoDetailView(title: UIStrings.administrativeArea, information: self.photo.administrativeArea)
                    PhotoDetailView(title: UIStrings.country, information: self.photo.country)
                    PhotoDetailView(title: UIStrings.countryCode, information: self.photo.isoCountryCode)
                    PhotoDetailView(title: UIStrings.name, information: self.photo.name)
                    PhotoDetailView(title: UIStrings.postalCode, information: self.photo.postalCode)
                    PhotoDetailView(title: UIStrings.ocean, information: self.photo.ocean)
                }
                Section {
                    PhotoDetailView(title: UIStrings.inlandWater, information: self.photo.inlandWater)
                    PhotoDetailView(title: UIStrings.areasOfInterest, information: self.photo.areasOfInterest.joined(separator: ","))
                }
            }
            .listStyle(.plain)
            .navigationTitle(UIStrings.details)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        self.dismiss()
                    } label: {
                        SheetDismissButtonView()
                    }
                }
            }
        }
    }

    func getDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Links.regularDateOnlyFormat
        return dateFormatter.string(from: date)
    }

    func getTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Links.regularTimeOnlyFormat
        return dateFormatter.string(from: date)
    }
}

struct PhotoDetailView: View {
    var title: String
    var information: String
    var body: some View {
        if !self.information.isEmpty {
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
