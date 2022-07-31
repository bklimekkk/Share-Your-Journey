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
            "name": journey.name,
            "email" : journey.email,
            "photosNumber" : journey.numberOfPhotos,
            "date" : Date(),
            "deletedJourney" : false
        ])
        
        let path = "users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "" )/friends/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/journeys/\(journey.name)/photos"
        
        FirebaseSetup.firebaseInstance.db.collection(path).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                //All photos details are stored inside document representing particular journey.
                for i in querySnapshot!.documents.sorted(by: { $0["photoNumber"] as! Int > $1["photoNumber"] as! Int }) {
                    FirebaseSetup.firebaseInstance.db.document("users/\(FirebaseSetup.firebaseInstance.auth.currentUser?.email ?? "")/friends/\(targetEmail)/journeys/\(journey.name)/photos/\(i.documentID)").setData([
                        "latitude": i.get("latitude") as! CLLocationDegrees,
                        "longitude": i.get("longitude") as! CLLocationDegrees,
                        "photoUrl": i.get("photoUrl") as! String,
                        "photoNumber": i.get("photoNumber") as! Int
                    ])
                }
            }
        }
    }
    
}
