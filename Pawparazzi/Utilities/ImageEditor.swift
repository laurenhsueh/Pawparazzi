//
//  ImageEditor.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//
import SwiftUI
import UIKit

// MARK: - Helper function to crop to square
func cropToSquare(image: UIImage) -> UIImage {
    let originalSize = image.size
    let length = min(originalSize.width, originalSize.height)
    let x = (originalSize.width - length) / 2
    let y = (originalSize.height - length) / 2
    let cropRect = CGRect(x: x, y: y, width: length, height: length)
    
    guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return image }
    return UIImage(cgImage: cgImage)
}

// MARK: - UIImage Resize Extension
extension UIImage {
    func resize(maxWidth: CGFloat) -> UIImage {
        let aspect = size.height / size.width
        let newWidth = min(size.width, maxWidth)
        let newHeight = newWidth * aspect
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 0.7)
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized ?? self
    }
}
