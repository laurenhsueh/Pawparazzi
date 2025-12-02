//
//  SearchBar.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    // Custom initializer so placeholder can be optional when used
    init(text: Binding<String>, placeholder: String = "Search") {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.red)

            TextField(placeholder, text: $text)
                .font(.custom("Inter-Regular", size: 14))
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)

            // Clear Button
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.6))
        )
        .padding(.horizontal, 16)
    }
}
