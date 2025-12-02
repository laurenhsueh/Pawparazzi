//
//  DescriptionEditor.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//
import SwiftUI

struct DescriptionEditor: View {
    @Binding var text: String
    var placeholder: String = "Write a description..."

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(AppColors.mutedText)
                    .padding(4)
                    .font(.custom("Inter-Regular", size: 14))
            }
            
            TextEditor(text: $text)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundStyle(.primary)
                .padding(4)
                .frame(height: 120)
                .cornerRadius(8)
        }
    }
}
