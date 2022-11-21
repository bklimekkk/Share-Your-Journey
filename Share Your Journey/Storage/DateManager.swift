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
        dateFormatter.dateFormat = "dd/MM/YY, hh:mm"
        return dateFormatter.string(from: date)
    }
}
