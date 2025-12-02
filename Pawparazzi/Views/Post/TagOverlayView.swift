//
//  TagOverlayView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//

import SwiftUI

struct TagOverlayView: View {
    @Binding var selectedTags: Set<String>
    @Binding var showOverlay: Bool
    var categorizedTags: [String: [String]]
    
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { showOverlay = false }
            
            VStack(spacing: 0) {
                Spacer()
                
                cardView
                    .frame(height: UIScreen.main.bounds.height * 0.85)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .animation(.easeInOut, value: showOverlay)
        .transition(.opacity)
    }
    
    
    // MARK: - Card Content
    private var cardView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Tags")
                    .font(.custom("AnticDidone-Regular", size: 24))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: { showOverlay = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(8) // easier tap target
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.red)
                TextField("Search", text: $searchText)
                    .font(.custom("Inter-Regular", size: 14))
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.6)))
            .padding(.horizontal, 16)
            
            // Scrollable tags
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(categorizedTags.keys.sorted(), id: \.self) { category in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(category)
                                .font(.subheadline)
                                .bold()
                            
                            let tags = categorizedTags[category]!.filter {
                                searchText.isEmpty || $0.lowercased().contains(searchText.lowercased())
                            }
                            
                            FlexibleView(
                                availableWidth: UIScreen.main.bounds.width - 32,
                                data: tags,
                                spacing: 8,
                                alignment: .leading
                            ) { tag in
                                Text(tag)
                                    .tagOutline(isSelected: selectedTags.contains(tag))
                                    .onTapGesture { toggleTag(tag: tag) }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            
            // Save button
            Button {
                // selectedTags is already updated through bindings when user taps tags
                showOverlay = false
            } label: {
                Text("Save Tags (\(selectedTags.count))")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
    }
    
    
    // MARK: - Toggle Tag
    private func toggleTag(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}


// MARK: - Rounded corner helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var elementsSize: [Data.Element: CGSize] = [:]
    
    private var rows: [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var widthUsed: CGFloat = 0
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            if widthUsed + elementSize.width + spacing > availableWidth {
                rows.append([element])
                widthUsed = elementSize.width + spacing
            } else {
                rows[rows.count - 1].append(element)
                widthUsed += elementSize.width + spacing
            }
        }
        
        return rows
    }
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex], id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: ElementsSizeKey.self,
                                            value: [element as AnyHashable: geo.size]
                                        )
                                }
                            )
                    }
                }
            }
        }
        .onPreferenceChange(ElementsSizeKey.self) { preferences in
            for (key, value) in preferences {
                if let element = key as? Data.Element {
                    elementsSize[element] = value
                }
            }
        }
    }
}

// MARK: - Preference Key
struct ElementsSizeKey: PreferenceKey {
    static var defaultValue: [AnyHashable: CGSize] = [:]
    
    static func reduce(value: inout [AnyHashable: CGSize], nextValue: () -> [AnyHashable: CGSize]) {
        value.merge(nextValue()) { $1 }
    }
}
