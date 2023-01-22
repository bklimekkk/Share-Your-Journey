//
//  FirestorePaths.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 02/01/2023.
//

import Foundation

struct FirestorePaths {

    static func getUsers() -> String {
        return "users"
    }

    static func myJourneys(uid: String) -> String {
        return "users/\(uid)/friends/\(uid)/journeys"
    }

    static func getFriends(uid: String) -> String {
        return "users/\(uid)/friends"
    }

    static func getRequests(uid: String) -> String {
        return "users/\(uid)/requests"
    }
}
