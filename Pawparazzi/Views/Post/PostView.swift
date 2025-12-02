//
//  PostView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct PostView: View {
    @StateObject private var manager = SupabaseManager.shared
    @StateObject private var locationManager = LocationManager()
    private let cardWidth = UIScreen.main.bounds.width - 32
    
    // MARK: - Photo
    @State private var selectedPhotoData: Data?
    
    // MARK: - Tags
    @State private var categorizedTags: [String: [String]] = TagData.categorizedTags
    @State private var quickTags: [String] = TagData.quickTags

    @State private var selectedTags: Set<String> = []
    
    @State private var showAllTagsOverlay: Bool = false
    
    // MARK: - Location & Description
    @State private var customLocation: String = ""
    @State private var descriptionText: String = "Write a description..."
    
    // MARK: - Cat Info
    @State private var catName: String = ""
    
    // MARK: - Upload State
    @State private var isUploading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Header
                HStack(alignment: .bottom) {
                    Text("New Post")
                        .font(.custom("AnticDidone-Regular", size: 40))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    Button {
                        Task {
                            await postCat()
                        }
                    } label: {
                        Text(isUploading ? "Uploading..." : "Post")
                            .font(.custom("Inter-Regular", size: 18))
                            .foregroundStyle(AppColors.accent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .cornerRadius(12)
                    }
                    .disabled(catName.isEmpty || selectedPhotoData == nil || isUploading)
                }
                .padding(.horizontal, 24)
                
                // MARK: - Card
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Photo Picker
                    PhotoPickerView(photoData: $selectedPhotoData, cardWidth: cardWidth - 32)
                    
                    // Cat Name
                    ZStack(alignment: .leading) {
                        if catName.isEmpty {
                            Text("Give a name...")
                                .foregroundStyle(AppColors.mutedText)
                                .font(.custom("AnticDidone-Regular", size: 32))
                                .padding(.vertical, 4)
                        }
                        TextField("", text: $catName)
                            .font(.custom("AnticDidone-Regular", size: 32))
                            .foregroundStyle(.primary)
                            .textFieldStyle(.plain)
                            .padding(.vertical, 4)
                    }
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Header
                        HStack {
                            Image(systemName: "star.circle")
                            Text("Add Tags")
                                .font(.custom("Inter-Regular", size: 14))
                            Spacer()
                        }
                        
                        // Quick tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                
                                // Show selected tags if they exist
                                if !selectedTags.isEmpty {
                                    ForEach(Array(selectedTags), id: \.self) { tag in
                                        Text(tag)
                                            .tagOutline(isSelected: true)
                                            .onTapGesture {
                                                toggleTag(tag: tag)
                                            }
                                    }
                                    
                                    // Otherwise show default unselected recommended tags
                                } else {
                                    ForEach(quickTags, id: \.self) { tag in
                                        Text(tag)
                                            .tagOutline(isSelected: false)
                                            .onTapGesture {
                                                toggleTag(tag: tag)
                                            }
                                    }
                                }
                                
                                Spacer()
                                
                                // More button
                                Button("more >") {
                                    showAllTagsOverlay = true
                                }
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                    
                    
                    Divider()
                    
                    // Location
                    HStack {
                        Image("PawIcon")
                        Text("Add Location")
                            .font(.custom("Inter-Regular", size: 14))
                        Spacer()
                        Button { locationManager.startUpdating() } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.plain)
                    }
                    Divider()
                    
                    // Description
                    DescriptionEditor(text: $descriptionText)
                    
                }
                .padding(16)
                .frame(width: cardWidth)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .shadow(color: AppColors.cardShadow, radius: 5, x: 0, y: 2)
                
            }
        }
        .padding(.vertical, 16)
        .background(AppColors.background)
        .overlay {
            if showAllTagsOverlay {
                TagOverlayView(
                    selectedTags: $selectedTags,
                    showOverlay: $showAllTagsOverlay,
                    categorizedTags: categorizedTags
                )
            }
        }
    }
    
    // MARK: - Functions
    private func toggleTag(tag: String) {
        if selectedTags.contains(tag) { selectedTags.remove(tag) }
        else { selectedTags.insert(tag) }
    }
    
    private func postCat() async {
        guard let photoData = selectedPhotoData else { return }
        isUploading = true
        
        var tagsDict: [String: String] = [:]
        for category in categorizedTags.keys {
            if let tag = categorizedTags[category]?.first(where: { selectedTags.contains($0) }) {
                tagsDict[category.lowercased()] = tag
            }
        }
        
        await manager.createCatWithPhotos(
            name: catName,
            description: descriptionText,
            location: locationManager.city.isEmpty ? customLocation : locationManager.city,
            tags: tagsDict,
            imageDataArray: [photoData]
        )
        
        // Reset form
        catName = ""
        selectedPhotoData = nil
        selectedTags = []
        descriptionText = "Write a description..."
        customLocation = ""
        isUploading = false
    }
}

#Preview {
    PostView()
}
