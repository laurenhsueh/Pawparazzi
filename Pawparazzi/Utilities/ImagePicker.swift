//
//  ImagePicker.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//

import SwiftUI
import UIKit
import ImageIO
import UniformTypeIdentifiers

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var photoData: Binding<Data?>? = nil
    var allowsEditing: Bool = true
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Coordinator to handle delegate methods
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        // Called when user picks an image
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let chosenImage: UIImage?
            if parent.allowsEditing {
                chosenImage = info[.editedImage] as? UIImage
            } else {
                chosenImage = info[.originalImage] as? UIImage
            }

            parent.image = chosenImage
            parent.photoData?.wrappedValue = parent.makeImageData(from: info, image: chosenImage)
            
            picker.dismiss(animated: true)
        }
        
        // Called when user cancels
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = allowsEditing
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update dynamically
    }

    /// Extract image data while preserving metadata like GPS when available.
    private func makeImageData(from info: [UIImagePickerController.InfoKey: Any], image: UIImage?) -> Data? {
        if let url = info[.imageURL] as? URL {
            return try? Data(contentsOf: url)
        }

        if let metadata = info[.mediaMetadata] as? [String: Any],
           let cgImage = image?.cgImage {
            let destinationData = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(
                destinationData,
                UTType.jpeg.identifier as CFString,
                1,
                nil
            ) else {
                return image?.jpegData(compressionQuality: 0.9)
            }

            CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
            if CGImageDestinationFinalize(destination) {
                return destinationData as Data
            }
        }

        return image?.jpegData(compressionQuality: 0.9)
    }
}
