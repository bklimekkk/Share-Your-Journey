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

    static func myJourneys(email: String) -> String {
        return "users/\(email)/friends/\(email)/journeys"
    }

    static func getFriends(email: String) -> String {
        return "users/\(email)/friends"
    }

    static func getRequests(email: String) -> String {
        return "users/\(email)/requests"
    }
}
