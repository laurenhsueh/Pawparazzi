//
//  Tag.swift
//  Pawparazzi
//
//  Created by iya student on 11/20/25.
//

import SwiftUI

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
                .fill(Color.white)
            )
            .foregroundStyle(Color.black.opacity(0.6))
    }
}

extension View {
    func tag() -> some View {
        modifier(Tag())
    }
}
