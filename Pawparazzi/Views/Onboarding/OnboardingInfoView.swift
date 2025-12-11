//
//  OnboardingInfoView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/7/25.
//
import SwiftUI

struct OnboardingInfoView: View {
    var next: () -> Void
    var back: () -> Void

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                ZStack(alignment: .topLeading) {

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {

                            // Top banner
                            Image("InfoBanner")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: AppColors.background.opacity(1.0), location: 0.0),
                                            .init(color: .clear, location: 0.2),
                                            .init(color: .clear, location: 0.9),
                                            .init(color: AppColors.background.opacity(0.5), location: 1.0),
                                        ]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    .clipped()
                                )

                            VStack(spacing: 24) {

                                Text("Become a Cat Paparazzi")
                                    .font(.custom("AnticDidone-Regular", size: 32))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 24)

                                VStack(spacing: 20) {
                                    InfoCardView(
                                        iconName: "camera.fill",
                                        title: "Capture & Share",
                                        text: "Snap photos of street cats and share their unique personalities with the community"
                                    )

                                    InfoCardView(
                                        iconName: "mappin.and.ellipse",
                                        title: "Map Your Findings",
                                        text: "Tag locations and create a visual map of all the cats in your area"
                                    )

                                    InfoCardView(
                                        iconName: "person.2.fill",
                                        title: "Join the Community",
                                        text: "Follow friends, discover new cats, and celebrate our feline neighbors together"
                                    )
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                        }
                    }

                    // Back button OVER the image
                    Button(action: back) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(AppColors.primaryAction)
                            .font(.system(size: 20, weight: .medium))
                            .padding()
                    }
                    .padding(.leading, 20)
                    .padding(.top, 32)
                }

                // Sticky bottom button
                VStack {
                    Button(action: next) {
                        Text("Continue")
                            .font(.custom("Inter-Regular", size: 18))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accent)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppColors.background)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    OnboardingInfoView(
        next: { },
        back: { }
    )
}