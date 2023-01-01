//
//  DateManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 14/08/2022.
//

import Foundation

struct DateManager {
    func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Links.regularDateFormat
        return dateFormatter.string(from: date)
    }
}
