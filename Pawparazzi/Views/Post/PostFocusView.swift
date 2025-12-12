//
//  PostFocusView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//


import SwiftUI

struct PostFocusView: View {
    @Environment(\.dismiss) private var dismiss
    let cat: CatModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                PostCard(cat: cat)
                    .padding(.top, 60)
            }

            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(12)
                    .background(.thinMaterial)
                    .clipShape(Circle())
            }
            .padding(.leading, 16)
            .padding(.top, 16)
        }
    }
}
