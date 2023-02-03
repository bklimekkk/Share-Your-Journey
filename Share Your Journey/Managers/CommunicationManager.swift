//
//  CommunicationManager.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/02/2023.
//

import Foundation
import UIKit

struct CommunicationManager {
    static func sendPhotoViaSocialMedia(image: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [image],applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController!.present(activityViewController, animated: true, completion: nil)
    }

    static func sendPhotosViaSocialMedia(images: [UIImage]) {
        let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController!.present(activityViewController, animated: true, completion: nil)
    }
}
