//
//  FieldStyles.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/2/25.
//
import SwiftUI

struct PasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isHidden: Bool
    
    var body: some View {
        HStack {
            if isHidden {
                SecureField(title, text: $text)
                    .font(.custom("Inter-Regular", size: 14))
            } else {
                TextField(title, text: $text)
                    .font(.custom("Inter-Regular", size: 14))
            }
            
            Button(action: { isHidden.toggle() }) {
                Image(systemName: isHidden ? "eye.slash" : "eye")
                    .foregroundStyle(AppColors.mutedText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.fieldBorder)
        )
        .padding(.horizontal, 16)
    }
}


extension View {
    func fieldStyle() -> some View {
        self.padding(8)
            .font(.custom("Inter-Regular", size: 14))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.fieldBorder)
            )
            .padding(.horizontal, 16)
    }
}
