//
//  SendJourneyManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 31/07/2022.
//

import Foundation
import Firebase
import MapKit

struct SendJourneyManager {
    /**
     Function is responsible for sending entire journey to particular user.
     */
    func sendJourney(journey: SingleJourney, targetUID: String) {
        
        //Journey is added to relevant collection in the firestore database (without photos references).
        Firestore.firestore().document("\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(targetUID)/journeys/\(journey.name)").setData([
            "name" : journey.name,
            "place": journey.place,
            "uid" : journey.uid,
            "photosNumber" : journey.numberOfPhotos,
            "date" : journey.date,
            "operationDate": Date.now,
            "deletedJourney" : false
        ])
        let path = "\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(Auth.auth().currentUser?.uid ?? "")/journeys/\(journey.name)/photos"
        Firestore.firestore().collection(path).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                //All photos details are stored inside document representing particular journey.
                for photo in querySnapshot!.documents.sorted(by: { $0["date"] as? Int ?? IntConstants.defaultValue > $1["date"] as? Int ?? IntConstants.defaultValue }) {
                    Firestore.firestore().document("\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? ""))/\(targetUID)/journeys/\(journey.name)/photos/\(photo.documentID)").setData([
                        "photoUrl": photo.get("photoUrl") as? String ?? UIStrings.emptyString,
                        "latitude": photo.get("latitude") as? CLLocationDegrees ?? CLLocationDegrees(),
                        "longitude": photo.get("longitude") as? CLLocationDegrees ?? CLLocationDegrees(),
                        "location": photo.get("location") as? String ?? UIStrings.emptyString,
                        "subLocation": photo.get("subLocation") as? String ?? UIStrings.emptyString,
                        "administrativeArea": photo.get("administrativeArea") as? String ?? UIStrings.emptyString,
                        "country": photo.get("country") as? String ?? UIStrings.emptyString,
                        "isoCountryCode": photo.get("isoCountryCode") as? String ?? UIStrings.emptyString,
                        "name": photo.get("name") as? String ?? UIStrings.emptyString,
                        "postalCode": photo.get("postalCode") as? String ?? UIStrings.emptyString,
                        "ocean": photo.get("ocean") as? String ?? UIStrings.emptyString,
                        "inlandWater": photo.get("inlandWater") as? String ?? UIStrings.emptyString,
                        "areasOfInterest": photo.get("areasOfInterest") as? String ?? UIStrings.emptyString
                    ])
                }
            }
        }
        NotificationSender.sendNotification(myNickname: UserDefaults.standard.string(forKey: "nickname") ?? UIStrings.emptyString,
                                            uid: targetUID,
                                            title: UIStrings.newJourneyNotificationTitle,
                                            body: "\(UserDefaults.standard.string(forKey: "nickname") ?? UIStrings.emptyString) just sent you a journey")
    }
}
