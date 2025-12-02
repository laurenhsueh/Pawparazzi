//
//  WelcomeStep.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//

import SwiftUI

struct WelcomeStep: View {
    var next: () -> Void
    var goToLogin: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 24) {
                Text("Welcome to Pawparazzi!")
                    .font(.custom("AnticDidone-Regular", size: 28))
                
                Text("Get ready to take pics of cats 🐾")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundStyle(AppColors.mutedText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            
            Button(action: next) {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(16)
            
            Button(action: goToLogin) {
                Text("I already have an account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(AppColors.primaryAction)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primaryAction, lineWidth: 2)
                    )
            }
            .padding(16)
        }
    }
}
