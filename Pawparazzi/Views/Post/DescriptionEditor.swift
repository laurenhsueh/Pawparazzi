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
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundStyle(AppColors.mutedText)
                    .padding(4)
            }
            
            TextEditor(text: $text)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundStyle(.primary)
                .frame(height: 90)
                .scrollContentBackground(.hidden) // hide default (black) background
                // .overlay(
                //     RoundedRectangle(cornerRadius: 8)
                //         .stroke(AppColors.fieldBorder)
                // )
        }
    }
}
