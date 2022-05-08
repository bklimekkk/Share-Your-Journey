//
//  UIImageTransformer.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 03/03/2022.
//

import Foundation
import UIKit

class UIImageTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let images = value as? UIImage else {return nil}
        
        do {
            let imageData = try NSKeyedArchiver.archivedData(withRootObject: images, requiringSecureCoding: true)
            return imageData
        } catch {
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let imagesData = value as? Data else {return nil}
        
        do {
            let image = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: imagesData)
            return image
        } catch {
            return nil
        }
    }
}
