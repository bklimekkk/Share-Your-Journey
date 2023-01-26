//
//  UserSettings.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 26/01/2023.
//

import Foundation

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    @Published var nickname = UserDefaults.standard.value(forKey: "nickname") as? String ?? UIStrings.emptyString
}
