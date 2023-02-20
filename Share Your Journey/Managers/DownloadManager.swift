//
//  DownloadManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 20/02/2023.
//

import Foundation
import Firebase
import SwiftUI

struct DownloadManager {
    @Environment(\.managedObjectContext) var moc
    var author: String
    /**
     Function is responsible for saving the journey in Core Data.
     */
    func downloadJourney(journey: SingleJourney) {
        let newJourney = Journey(context: self.moc)
        newJourney.name = journey.name
        newJourney.place = journey.place
        newJourney.uid = Auth.auth().currentUser?.uid
        newJourney.author = self.author
        newJourney.date = journey.date
        newJourney.operationDate = Date.now
        newJourney.photosNumber = (journey.numberOfPhotos) as NSNumber
        var index = 0
        while index < journey.photos.count {
            let newImage = Photo(context: moc)
            newImage.id = Double(index + 1)
            newImage.journey = newJourney
            newImage.image = journey.photos[index].photo.jpegData(compressionQuality: 0.5)
            newImage.latitude = journey.photosLocations[index].latitude
            newImage.longitude = journey.photosLocations[index].longitude
            newImage.location = journey.photos[index].location
            newImage.subLocation = journey.photos[index].subLocation
            newImage.administrativeArea = journey.photos[index].administrativeArea
            newImage.country = journey.photos[index].country
            newImage.isoCountryCode = journey.photos[index].isoCountryCode
            newImage.name = journey.photos[index].name
            newImage.postalCode = journey.photos[index].postalCode
            newImage.ocean = journey.photos[index].ocean
            newImage.inlandWater = journey.photos[index].inlandWater
            newImage.areasOfInterest = journey.photos[index].areasOfInterest.joined(separator: ",")
            newJourney.addToPhotos(newImage)
            index+=1
        }

        //After all journey properties are set, changes need to be saved with context variable's function: save().
        try? self.moc.save()
    }
}
