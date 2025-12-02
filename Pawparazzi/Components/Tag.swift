//
//  Tag.swift
//  Pawparazzi
//
//  Created by iya student on 11/20/25.
//
import SwiftUI

// MARK: - Filled Tag
struct Tag: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 4,
                        bottomLeading: 4,
                        bottomTrailing: 8,
                        topTrailing: 8
                    )
                )
                .fill(AppColors.cardBackground)
            )
            .foregroundStyle(AppColors.mutedText)
    }
}

extension View {
    func tag() -> some View {
        modifier(Tag())
    }
}
// MARK: - Outline Tag
struct TagOutline: ViewModifier {
    var isSelected: Bool = false
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 4,
                        bottomLeading: 4,
                        bottomTrailing: 8,
                        topTrailing: 8
                    )
                )
                .fill(AppColors.cardBackground)
            )
            .overlay(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 4,
                        bottomLeading: 4,
                        bottomTrailing: 8,
                        topTrailing: 8
                    )
                )
                .stroke(isSelected ? AppColors.accent : AppColors.fieldBorder, lineWidth: 1)
            )
            .foregroundStyle(.primary)
    }
}

extension View {
    func tagOutline(isSelected: Bool = false) -> some View {
        modifier(TagOutline(isSelected: isSelected))
    }
}

// MARK: - Tag Box View
struct TagBox: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Text(tag)
            .font(.subheadline)
            .padding(8)
            .background(isSelected ? AppColors.accent : AppColors.accentSoftBackground)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
            .onTapGesture { action() }
    }
}
