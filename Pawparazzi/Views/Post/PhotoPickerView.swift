//
//  PhotoPickerView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var photoData: Data?
    let cardWidth: CGFloat

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardWidth)
                        .clipped()
                        .cornerRadius(4)
                } else {
                    Rectangle()
                        .fill(AppColors.secondarySystemBackground)
                        .frame(width: cardWidth, height: cardWidth)
                    VStack(spacing: 16) {
                        Image(systemName: "camera")
                            .font(.system(size: 50))
                            .foregroundStyle(AppColors.mutedText)
                        Text("Tap to add photo")
                            .foregroundStyle(AppColors.mutedText)
                            .font(.custom("Inter-Regular", size: 14))
                    }
                }
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let squareImage = cropToSquare(image: uiImage)
                    let resizedData = squareImage.resize(maxWidth: 1024).jpegData(compressionQuality: 0.6)
                    photoData = resizedData
                }
            }
        }
    }
}
