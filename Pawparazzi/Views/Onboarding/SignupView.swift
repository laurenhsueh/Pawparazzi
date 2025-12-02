//
//  SignupView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//
import SwiftUI

struct SignupView: View {
    @ObservedObject var model: OnboardingModel
    var next: () -> Void
    var back: () -> Void
    var goToLogin: () -> Void
    
    @State private var isPasswordHidden = true
    @State private var isConfirmPasswordHidden = true
    
    var body: some View {
        VStack(spacing: 24) {
            // Top bar
            HStack {
                Button(action: back) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .medium))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Title
            Text("Set up your account")
                .font(.custom("AnticDidone-Regular", size: 40))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            // Email field
            TextField("Email", text: $model.email)
                .fieldStyle()
            
            // Password fields
            PasswordField(title: "Password", text: $model.password, isHidden: $isPasswordHidden)
            PasswordField(title: "Confirm Password", text: $model.confirmPassword, isHidden: $isConfirmPasswordHidden)
            
            Spacer()
            
            // Continue button
            Button(action: next) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("Secondary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            
            // Divider & Login
            HStack {
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                Text("or").foregroundColor(.gray)
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
            }
            .padding(.horizontal, 16)
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                    .font(.custom("Inter-Regular", size: 12))
                Button(action: goToLogin) {
                    Text("Log in")
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                        .font(.custom("Inter-Regular", size: 12))
                }
            }
            .padding(.bottom, 16)
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }
}
