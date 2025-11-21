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
    
    // MARK: - Photo
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    
    // MARK: - Tags
    @State private var categorizedTags: [String: [String]] = [
        "Breed": ["Siamese", "Persian", "Maine Coon", "Bengal", "Ragdoll", "Sphynx"],
        "Color": ["Black", "White", "Gray", "Orange", "Spotted"],
        "Status": ["Overfed", "Needs Medical", "Healthy", "Shy"],
        "Personality": ["Playful", "Curious", "Friendly", "Calm", "Sleepy"]
    ]
    
    // Quick tags for main display
    @State private var quickTags: [String] = ["Shy", "Playful", "Overfed", "Needs Medical"]
    
    // Set of selected tags
    @State private var selectedTags: Set<String> = []
    
    // Overlay
    @State private var showAllTagsOverlay: Bool = false
    
    // MARK: - Location & Description
    @State private var customLocation: String = ""
    @State private var descriptionText: String = ""
    
    // MARK: - Cat Info
    @State private var catName: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Photo Square
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(15)
                        } else {
                            Rectangle()
                                .fill(Color(.secondarySystemFill))
                                .frame(height: 250)
                                .cornerRadius(15)
                            VStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("Tap to add photo")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            }
                        }
                    }
                }
                .onChange(of: selectedPhotoItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                        }
                    }
                }
                
                // MARK: - Cat Name
                TextField("Cat Name", text: $catName)
                    .textFieldStyle(.roundedBorder)
                
                // MARK: - Tags Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Tags")
                        .font(.title2)
                        .bold()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickTags, id: \.self) { tag in
                                TagBox(tag: tag, isSelected: selectedTags.contains(tag)) {
                                    toggleTag(tag: tag)
                                }
                            }
                            
                            // More button
                            Button {
                                showAllTagsOverlay = true
                            } label: {
                                HStack {
                                    Image(systemName: "ellipsis.circle")
                                    Text("More")
                                }
                                .padding(8)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                
                // MARK: - All Tags Overlay
                if showAllTagsOverlay {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("All Tags")
                                .font(.headline)
                            Spacer()
                            Button("Close") {
                                showAllTagsOverlay = false
                            }
                        }
                        
                        ForEach(categorizedTags.keys.sorted(), id: \.self) { category in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(category)
                                    .font(.subheadline)
                                    .bold()
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                                    ForEach(categorizedTags[category]!, id: \.self) { tag in
                                        TagBox(tag: tag, isSelected: selectedTags.contains(tag)) {
                                            toggleTag(tag: tag)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
                
                // MARK: - Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Location")
                        .font(.headline)
                    HStack {
                        Text(locationManager.city.isEmpty ? (customLocation.isEmpty ? "Tap to detect or enter location" : customLocation) : locationManager.city)
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            locationManager.startUpdating()
                        } label: {
                            Image(systemName: "location.fill")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemFill))
                    .cornerRadius(10)
                }
                
                // MARK: - Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Write Description")
                        .font(.headline)
                    TextEditor(text: $descriptionText)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(10)
                }
                
                // MARK: - Post Button
                Button {
                    Task {
                        await postCat()
                    }
                } label: {
                    Text("Post")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(catName.isEmpty || selectedPhotoData == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(catName.isEmpty || selectedPhotoData == nil)
                
            }
            .padding()
        }
    }
    
    // MARK: - Functions
    private func toggleTag(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    private func postCat() async {
        guard let photoData = selectedPhotoData else { return }
        
        // Convert tags into dictionary (choose category based on your backend or just lowercase)
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
        descriptionText = ""
        customLocation = ""
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
            .background(isSelected ? Color.blue.opacity(0.7) : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
            .onTapGesture {
                action()
            }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var city: String = ""
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            guard let self = self else { return }
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.city = city
                    self.manager.stopUpdatingLocation()
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
