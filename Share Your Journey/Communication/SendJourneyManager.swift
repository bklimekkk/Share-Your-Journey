//
//  SendJourneyManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 31/07/2022.
//

import Foundation
import MapKit

struct SendJourneyManager {
    /**
     Function is responsible for sending entire journey to particular user.
     */
    func sendJourney(journey: SingleJourney, targetEmail: String) {
        
        //Journey is added to relevant collection in the firestore database (without photos references).
        FirebaseSetup.firebaseInstance.db.document("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(targetEmail)/journeys/\(journey.name)").setData([
            "name" : journey.name,
            "place": journey.place,
            "email" : journey.email,
            "photosNumber" : journey.numberOfPhotos,
            "date" : Date(),
            "deletedJourney" : false
        ])
        let path = "users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString )/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? UIStrings.emptyString)/journeys/\(journey.name)/photos"
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                //All photos details are stored inside document representing particular journey.
                for i in querySnapshot!.documents.sorted(by: { $0["photoNumber"] as! Int > $1["photoNumber"] as! Int }) {
                    FirebaseSetup.firebaseInstance.db.document("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(targetEmail)/journeys/\(journey.name)/photos/\(i.documentID)").setData([
                        "photoUrl": i.get("photoUrl") as! String,
                        "photoNumber": i.get("photoNumber") as! Int,
                        "latitude": i.get("latitude") as! CLLocationDegrees,
                        "longitude": i.get("longitude") as! CLLocationDegrees,
                        "location": i.get("location") as! String,
                        "subLocation": i.get("subLocation") as! String,
                        "administrativeArea": i.get("administrativeArea") as! String,
                        "country": i.get("country") as! String,
                        "isoCountryCode": i.get("isoCountryCode") as! String,
                        "name": i.get("name") as! String,
                        "postalCode": i.get("postalCode") as! String,
                        "ocean": i.get("ocean") as! String,
                        "inlandWater": i.get("inlandWater") as! String,
                        "areasOfInterest": i.get("areasOfInterest") as! String
                    ])
                }
            }
        }
    }
}
