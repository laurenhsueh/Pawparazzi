//
//  LoginView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var isPasswordHidden = true
    
    var back: () -> Void      // NEW
    var goToSignUp: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Top bar
                HStack {
                    Button(action: back) {   // Uses closure
                        Image(systemName: "chevron.left")
                        .foregroundStyle(AppColors.primaryAction)
                            .font(.system(size: 20, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                Spacer()

                // MARK: - Title
                Text("Log in to your account")
                    .font(.custom("AnticDidone-Regular", size: 40))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                
                // MARK: - Email Field
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .fieldStyle()
                
                // MARK: - Password Field
                PasswordField(title: "Password", text: $viewModel.password, isHidden: $isPasswordHidden)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.custom("Inter-Regular", size: 12))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // MARK: - Login Button
                Button(action: {
                    Task {
                        await viewModel.login()
                    }
                }) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                        }
                    }
                    .font(.custom("Inter-Regular", size: 14))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primaryAction)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 16)
                
                // MARK: - Divider and Sign Up
                HStack {
                Rectangle().fill(AppColors.divider).frame(height: 1)
                Text("or").foregroundStyle(AppColors.mutedText)
                Rectangle().fill(AppColors.divider).frame(height: 1)
                }
                .padding(.horizontal, 16)
                
                HStack {
                    Text("Don't have an account?")
                    .foregroundStyle(AppColors.mutedText)
                        .font(.custom("Inter-Regular", size: 12))
                    Button(action: goToSignUp) {
                        Text("Sign up")
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
