//
//  SignupView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//
import SwiftUI

struct SignupView: View {
    @ObservedObject var model: OnboardingModel
    @ObservedObject var viewModel: SignupViewModel
    var next: () -> Void
    var back: () -> Void
    var goToLogin: () -> Void
    
    @State private var isPasswordHidden = true
    @State private var isConfirmPasswordHidden = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top bar
                HStack {
                    Button(action: back) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(AppColors.primaryAction)
                            .font(.system(size: 20, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                Spacer()

                // Title
                Text("Sign up for an account")
                    .font(.custom("AnticDidone-Regular", size: 40))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                
                // Username field
                TextField("Username", text: $model.username)
                    .fieldStyle()
                
                // Email field
                TextField("Email", text: $model.email)
                    .fieldStyle()
                
                // Password fields
                PasswordField(title: "Password", text: $model.password, isHidden: $isPasswordHidden)
                PasswordField(title: "Confirm Password", text: $model.confirmPassword, isHidden: $isConfirmPasswordHidden)

                Spacer()
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                }
                
                // Continue button
                Button(action: {
                    if viewModel.validateCredentials(using: model) {
                        next()
                    }
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 16)
                
                // Divider & Login
                HStack {
                Rectangle().fill(AppColors.divider).frame(height: 1)
                Text("or").foregroundStyle(AppColors.mutedText)
                Rectangle().fill(AppColors.divider).frame(height: 1)
                }
                .padding(.horizontal, 16)
                
                HStack {
                    Text("Already have an account?")
                    .foregroundStyle(AppColors.mutedText)
                        .font(.custom("Inter-Regular", size: 12))
                    Button(action: goToLogin) {
                        Text("Log in")
                        .foregroundColor(AppColors.primaryAction)
                            .fontWeight(.semibold)
                            .font(.custom("Inter-Regular", size: 12))
                    }
                }
                .padding(.bottom, 16)
            }
            .padding(.top, 24)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
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
}

#Preview {
    SignupView(
        model: OnboardingModel(),
        viewModel: SignupViewModel(),
        next: { },
        back: { },
        goToLogin: { }
    )
}
