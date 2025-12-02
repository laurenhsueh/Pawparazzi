//
//  LoginView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordHidden = true
    
    var back: () -> Void      // NEW
    var goToSignUp: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Top bar
            HStack {
                Button(action: back) {   // Uses closure
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .medium))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // MARK: - Title
            Text("Log in to your account")
                .font(.custom("AnticDidone-Regular", size: 40))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
            
            // MARK: - Email Field
            TextField("Email", text: $email)
                .fieldStyle()
            
            // MARK: - Password Field
            PasswordField(title: "Password", text: $password, isHidden: $isPasswordHidden)
            
            Spacer()
            
            // MARK: - Login Button
            Button(action: { print("Login tapped") }) {
                Text("Login")
                    .font(.custom("Inter-Regular", size: 14))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            
            // MARK: - Divider and Sign Up
            HStack {
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                Text("or").foregroundColor(.gray)
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
            }
            .padding(.horizontal, 16)
            
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                    .font(.custom("Inter-Regular", size: 12))
                Button(action: goToSignUp) {
                    Text("Sign up")
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
