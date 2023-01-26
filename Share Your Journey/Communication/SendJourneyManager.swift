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
        Firestore.firestore().document("\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString))/\(targetUID)/journeys/\(journey.name)").setData([
            "name" : journey.name,
            "place": journey.place,
            "uid" : journey.uid,
            "photosNumber" : journey.numberOfPhotos,
            "date" : journey.date,
            "operationDate": Date.now,
            "deletedJourney" : false
        ])
        let path = "\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString))/\(Auth.auth().currentUser?.uid ?? UIStrings.emptyString)/journeys/\(journey.name)/photos"
        Firestore.firestore().collection(path).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                //All photos details are stored inside document representing particular journey.
                for i in querySnapshot!.documents.sorted(by: { $0["photoNumber"] as? Int ?? IntConstants.defaultValue > $1["photoNumber"] as? Int ?? IntConstants.defaultValue }) {
                    Firestore.firestore().document("\(FirestorePaths.getFriends(uid: Auth.auth().currentUser?.uid ?? UIStrings.emptyString))/\(targetUID)/journeys/\(journey.name)/photos/\(i.documentID)").setData([
                        "photoUrl": i.get("photoUrl") as? String ?? UIStrings.emptyString,
                        "photoNumber": i.get("photoNumber") as? Int ?? IntConstants.defaultValue,
                        "latitude": i.get("latitude") as? CLLocationDegrees ?? CLLocationDegrees(),
                        "longitude": i.get("longitude") as? CLLocationDegrees ?? CLLocationDegrees(),
                        "location": i.get("location") as? String ?? UIStrings.emptyString,
                        "subLocation": i.get("subLocation") as? String ?? UIStrings.emptyString,
                        "administrativeArea": i.get("administrativeArea") as? String ?? UIStrings.emptyString,
                        "country": i.get("country") as? String ?? UIStrings.emptyString,
                        "isoCountryCode": i.get("isoCountryCode") as? String ?? UIStrings.emptyString,
                        "name": i.get("name") as? String ?? UIStrings.emptyString,
                        "postalCode": i.get("postalCode") as? String ?? UIStrings.emptyString,
                        "ocean": i.get("ocean") as? String ?? UIStrings.emptyString,
                        "inlandWater": i.get("inlandWater") as? String ?? UIStrings.emptyString,
                        "areasOfInterest": i.get("areasOfInterest") as? String ?? UIStrings.emptyString
                    ])
                }
            }
        }
        NotificationSender.sendNotification(myNickname: UserSettings.shared.nickname,
                                            uid: targetUID,
                                            title: UIStrings.newJourneyNotificationTitle,
                                            body: "\(UserSettings.shared.nickname) just sent you a journey")
    }
}
