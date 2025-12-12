//
//  CatImage.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/11/25.
//
import SwiftUI

struct CatImage: View {
    let url: URL?
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = 12
    var contentMode: ContentMode = .fill

    /// Passing a cat makes the image clickable → opens PostFocusView
    var focusCat: CatModel? = nil

    @State private var showFocus = false

    var body: some View {
        let imageContent = Group {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)

                case .empty, .failure:
                    Rectangle()
                        .fill(Color(.secondarySystemFill))

                @unknown default:
                    Rectangle()
                        .fill(Color(.secondarySystemFill))
                }
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .cornerRadius(cornerRadius)
        .contentShape(Rectangle()) // ensures full tap area

        // MARK: - Clickable or Not
        if let focusCat {
            imageContent
                .onTapGesture { showFocus = true }
                .fullScreenCover(isPresented: $showFocus) {
                    PostFocusView(cat: focusCat)
                }
        } else {
            imageContent
        }
    }
}
