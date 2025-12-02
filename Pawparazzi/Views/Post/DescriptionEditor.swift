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
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(4)
                    .font(.custom("Inter-Regular", size: 14))
            }
            
            TextEditor(text: $text)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.black)
                .padding(4)
                .frame(height: 120)
                .cornerRadius(8)
        }
    }
}
