//
//  SetupProfileView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//

import SwiftUI

struct SetupProfileView: View {
    @ObservedObject var model: OnboardingModel
    var next: () -> Void
    var back: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var step: Int = 1
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Back Button
            HStack {
                Button(action: {
                    if step == 1 { back() }
                    else { step -= 1 }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .medium))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // MARK: - Title
            Text("Set Up Profile")
                .font(.custom("AnticDidone-Regular", size: 40))
                .padding(.top)
            
            // MARK: - Progress Dots
            HStack(spacing: 8) {
                ForEach(1...3, id: \.self) { index in
                    Circle()
                        .fill(step == index ? Color.gray.opacity(0.9) : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            
            Spacer().frame(height: 20)
            
            // MARK: - Step Content
            Group {
                if step == 1 {
                    usernameStep
                } else if step == 2 {
                    nameStep
                } else {
                    photoStep
                }
            }
            .animation(.easeInOut, value: step)
            
            // MARK: - Next Button
            Button(action: {
                if step < 3 { step += 1 }
                else { next() }
            }) {
                Text(step < 3 ? "Next" : "Finish")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Secondary"))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            
        }
    }
    
    // MARK: - Step Views
    
    var usernameStep: some View {
        VStack(spacing: 12) {
            TextField("Username", text: $model.username)
                .fieldStyle()
        }
    }
    
    var nameStep: some View {
        VStack(spacing: 12) {
            TextField("Full Name", text: $model.name)
                .fieldStyle()
        }
    }
    
    var photoStep: some View {
        VStack(spacing: 20) {
            if let image = model.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                    .clipped()
            } else {
                Circle()
                    .fill(Color(.secondarySystemFill))
                    .frame(width: 160, height: 160)
                    .overlay(
                        Text("Add Photo")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.gray)
                    )
            }
            
            Button("Choose Photo") {
                showingImagePicker = true
            }
            .font(.custom("Inter-Regular", size: 16))
            .foregroundColor(Color("Secondary"))
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $model.profileImage)
        }
    }
}
