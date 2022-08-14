//
//  PhotoPickerView.swift
//  Share Your Journey
//
//  Created by Bartosz Klimek on 28/02/2022.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    @Environment(\.managedObjectContext) var moc
    @Binding var pickPhoto: Bool
    @Binding var photosArray: [SinglePhoto]

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var photoPickerView: PhotoPickerView
       
        init(photoPickerView: PhotoPickerView) {
            self.photoPickerView = photoPickerView
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let photo = info[.originalImage] as? UIImage {
                let photoArraySize = photoPickerView.photosArray.count
                photoPickerView.photosArray.append(SinglePhoto(number: photoArraySize,photo: photo))
            }
            picker.dismiss(animated:true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(photoPickerView: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = context.coordinator
        
            photoPicker.sourceType = pickPhoto ? .photoLibrary : .camera
        
        return photoPicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
