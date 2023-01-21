//
//  HapticFeedback.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 21/01/2023.
//

import Foundation
import SwiftUI

struct HapticFeedback {
    static func lightHapticFeedback() {
        let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
        hapticFeedback.impactOccurred()
    }

    static func mediumHapticFeedback() {
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedback.impactOccurred()
    }

    static func heavyHapticFeedback() {
        let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
        hapticFeedback.impactOccurred()
    }
}
