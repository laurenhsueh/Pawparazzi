//
//  WelcomeStep.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//
import SwiftUI

struct WelcomeStep: View {
    var next: () -> Void

    var body: some View {
        ZStack {
            AppColors.accent
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Pawparazzi")
                    .font(.custom("AnticDidone-Regular", size: 64))
                    .foregroundColor(.white)

                Text("Where Every Street Cat Becomes a Star")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 32)

                Button(action: next) {
                    Text("Get Started  >")
                        .padding()
                        .padding(.horizontal, 32)
                        .background(.white)
                        .foregroundColor(AppColors.accent)
                        .cornerRadius(24)
                }
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
