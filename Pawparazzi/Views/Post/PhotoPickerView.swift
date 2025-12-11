//
//  PhotoPickerView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//

import SwiftUI
import UIKit
import AVFoundation

struct PhotoPickerView: View {
    @Environment(\.openURL) private var openURL
    @Binding var photoData: Data?
    let cardWidth: CGFloat

    @State private var selectedUIImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var cameraUnavailableAlert = false
    @State private var cameraPermissionAlert = false

    var body: some View {
        Menu {
            Button {
                sourceType = .photoLibrary
                showImagePicker = true
            } label: {
                Label("Photo Library", systemImage: "photo.on.rectangle")
            }

            Button {
                handleCameraTap()
            } label: {
                Label("Camera", systemImage: "camera")
            }
        } label: {
            ZStack {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardWidth)
                        .clipped()
                        .cornerRadius(12)
                        .overlay(alignment: .bottomTrailing) {
                            Label("Change", systemImage: "pencil")
                                .font(.custom("Inter-Regular", size: 12))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.thinMaterial, in: Capsule())
                                .padding(8)
                        }
                        .transition(.opacity.combined(with: .scale))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColors.secondarySystemBackground)
                        .frame(width: cardWidth, height: cardWidth)
                        .overlay {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.cardBackground)
                                        .frame(width: 64, height: 64)
                                        .shadow(color: AppColors.cardShadow.opacity(0.4), radius: 12, x: 0, y: 8)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundStyle(AppColors.mutedText)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("Tap to add photo")
                                        .foregroundStyle(.primary)
                                        .font(.custom("Inter-Regular", size: 16))
                                    Text("Camera or library")
                                        .foregroundStyle(AppColors.mutedText)
                                        .font(.custom("Inter-Regular", size: 12))
                                }
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.fieldBorder, lineWidth: 1)
                        )
                        .transition(.opacity)
                }
            }
        }
        .menuStyle(.borderlessButton)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: photoData)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                image: $selectedUIImage,
                photoData: $photoData,
                allowsEditing: false,
                sourceType: sourceType
            )
                .ignoresSafeArea()
        }
        .alert("Camera not available", isPresented: $cameraUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Try again on a device with a camera or pick from your library.")
        }
        .alert("Camera permission needed", isPresented: $cameraPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enable camera access in Settings to capture a photo.")
        }
    }
}

// MARK: - Helpers
private extension PhotoPickerView {
    func handleCameraTap() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            cameraUnavailableAlert = true
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sourceType = .camera
            showImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        sourceType = .camera
                        showImagePicker = true
                    } else {
                        cameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionAlert = true
        @unknown default:
            cameraPermissionAlert = true
        }
    }
}
