//
//  SetupProfileView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//

import SwiftUI

struct SetupProfileView: View {
    @ObservedObject var model: OnboardingModel
    var isSubmitting: Bool
    var errorMessage: String?
    var next: () -> Void
    var back: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var step: Int = 1
    @State private var showingImagePicker = false
    private let totalSteps = 2
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Back Button
                HStack {
                    Button(action: {
                        if step == 1 { back() }
                        else { step -= 1 }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(AppColors.primaryAction)
                            .font(.system(size: 20, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // MARK: - Title
                Text("Profile setup")
                    .font(.custom("AnticDidone-Regular", size: 40))
                    .foregroundStyle(.primary)
                    .padding(.top)
                
                // MARK: - Step Content
                Group {
                    if step == 1 {
                        nameStep
                    } else {
                        photoStep
                    }
                }
                .animation(.easeInOut, value: step)
                
                Spacer(minLength: 0)
                
                // MARK: - Next Button
                Button(action: {
                    guard !isSubmitting else { return }
                    if step < totalSteps { step += 1 }
                    else { next() }
                }) {
                    Text(isSubmitting ? "Submitting..." : (step < totalSteps ? "Next" : "Finish"))
                        .font(.custom("Inter-Regular", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                }
                .disabled(isSubmitting)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // MARK: - Progress Dots
                HStack(spacing: 8) {
                    ForEach(1...totalSteps, id: \.self) { index in
                        Circle()
                            .fill(step == index ? AppColors.mutedText : AppColors.mutedText.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                
            }
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 16)
        }
        .background(
            AppColors.background
                .ignoresSafeArea(.container, edges: .all)
        )
    }
    
    // MARK: - Step Views
    
    var nameStep: some View {
        VStack(spacing: 12) {
            // TextField("Full Name", text: $model.name)
            //     .fieldStyle()
            TextField("City", text: $model.location)
                .fieldStyle()
            TextField("Bio", text: $model.bio)
                .fieldStyle()
        }.padding(.horizontal, 8)
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
                    .fill(AppColors.secondarySystemBackground)
                    .frame(width: 160, height: 160)
                    .overlay(
                        Text("Add Photo")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundStyle(AppColors.mutedText)
                    )
                    .onTapGesture {
                        showingImagePicker = true
                    }
            }
            
            // Button("Choose Photo") {
            //     showingImagePicker = true
            // }
            // .font(.custom("Inter-Regular", size: 16))
            // .foregroundColor(AppColors.accent)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $model.profileImage)
        }
    }
}

#Preview {
    SetupProfileView(
        model: OnboardingModel(),
        isSubmitting: false,
        errorMessage: nil,
        next: { },
        back: { }
    )
}
