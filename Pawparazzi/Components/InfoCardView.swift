//
//  InfoCardView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/7/25.
//

import SwiftUI

struct InfoCardView: View {
    var iconName: String
    var title: String
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Icon block
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.10))
                    .frame(width: 48, height: 48)

                Image(systemName: iconName)
                    .foregroundColor(AppColors.accent)
                    .font(.system(size: 20, weight: .semibold))
            }
            .padding(.trailing, 12)

            // Text block
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(text)
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundStyle(AppColors.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
                .shadow(color: AppColors.cardShadow.opacity(0.2), radius: 10, x: 0, y: 4)
        )
        .frame(maxWidth: 330) // makes cards narrower and cleaner
        .frame(maxWidth: .infinity) // centers the card
    }
}
