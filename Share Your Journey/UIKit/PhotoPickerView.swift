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
    @Binding var takePhotoCancelled: Bool
    @Binding var photosArray: [SinglePhoto]

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var photoPickerView: PhotoPickerView
       
        init(photoPickerView: PhotoPickerView) {
            self.photoPickerView = photoPickerView
        }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let photo = info[.originalImage] as? UIImage {
                let photoArraySize = self.photoPickerView.photosArray.count
                self.photoPickerView.photosArray.append(SinglePhoto(number: photoArraySize,photo: photo))
            }
            picker.dismiss(animated:true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.photoPickerView.takePhotoCancelled = true
            picker.dismiss(animated:true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(photoPickerView: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = context.coordinator
        
        photoPicker.sourceType = self.pickPhoto ? .photoLibrary : .camera
        
        return photoPicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
