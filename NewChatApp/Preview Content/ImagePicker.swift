//
//  ImagePicker.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-18.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    @Binding var imagePicker: Bool
    @Binding var imgData: Data

    private let controller = UIImagePickerController()

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

    }

    func makeUIViewController(context: Context) -> some UIViewController {
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

}

/* func makeCoordinator() -> Coordinator {
    
    return ImagePicker.Coordinator(parent1: self)
}

@Binding var imagePicker : Bool
@Binding var imgData : Data
@Binding var image : UIImage?

func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .photoLibrary
    picker.delegate = context.coordinator
    return picker
}
func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    
}

class Coordinator : NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var parent : ImagePicker
    
    init(parent1 : ImagePicker) {
        parent = parent1
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.imagePicker.toggle()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        parent.imgData = image.jpegData(compressionQuality: 0.5)!
        parent.imagePicker.toggle()
    }
}*/
