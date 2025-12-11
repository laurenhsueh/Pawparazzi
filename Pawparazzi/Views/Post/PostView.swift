//
//  PostView.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 11/18/25.
//

import SwiftUI
import PhotosUI
import CoreLocation
import MapKit
import ImageIO
import UIKit

struct PostView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var store = CatStore.shared
    @StateObject private var locationManager = LocationManager()
    private let cardWidth = UIScreen.main.bounds.width - 32
    /// Optional callback to jump the user back to the feed after posting.
    var onPostSuccess: (() -> Void)? = nil
    
    // MARK: - Photo
    @State private var selectedPhotoData: Data?
    
    // MARK: - Tags
    @State private var categorizedTags: [String: [String]] = TagData.categorizedTags
    @State private var quickTags: [String] = TagData.quickTags

    @State private var selectedTags: Set<String> = []
    
    @State private var showAllTagsOverlay: Bool = false
    
    // MARK: - Location & Description
    @State private var descriptionText: String = ""
    @State private var catName: String = ""
    @State private var pinnedCoordinate: CLLocationCoordinate2D?
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    @State private var locationOrigin: LocationOrigin = .none
    @State private var locationMessage: String = "Add a pin or let us detect it"
    @State private var isProgrammaticRegionUpdate = false
    @State private var showLocationPermissionAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 12) {
                    Text("New Post")
                        .font(.custom("AnticDidone-Regular", size: 40))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedPhotoData)
                
                if let error = store.postingError, !error.isEmpty {
                    Text(error)
                        .font(.custom("Inter-Regular", size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                // MARK: - Composer Card
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Photo Picker
                    PhotoPickerView(photoData: $selectedPhotoData, cardWidth: cardWidth - 32)
                        .frame(maxWidth: .infinity)
                    
                    // Cat Name + Description
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack(alignment: .leading) {
                            if catName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Give your cat a name")
                                    .foregroundStyle(AppColors.mutedText)
                                    .font(.custom("AnticDidone-Regular", size: 30))
                                    .padding(.vertical, 6)
                            }
                            TextField("", text: $catName)
                                .font(.custom("AnticDidone-Regular", size: 30))
                                .foregroundStyle(.primary)
                                .textFieldStyle(.plain)
                                .padding(.vertical, 6)
                        }
                    }
                    
                    Divider()
                    
                    // Tags Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Add Tags", systemImage: "tag.fill")
                                .font(.custom("Inter-Regular", size: 14))
                            Spacer()
                            Button {
                                showAllTagsOverlay = true
                            } label: {
                                Text("Browse all")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                let tagsToShow = !selectedTags.isEmpty ? Array(selectedTags) : quickTags
                                ForEach(tagsToShow, id: \.self) { tag in
                                    Text(tag)
                                        .tagOutline(isSelected: selectedTags.contains(tag))
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                                toggleTag(tag: tag)
                                            }
                                        }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    
                    Divider()
                    
                    // Location section with map widget
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Label("Location", systemImage: "mappin.and.ellipse")
                                .font(.custom("Inter-Regular", size: 14))
                            Spacer()
                            if locationOrigin != .none {
                                Text(locationOrigin.label)
                                    .font(.custom("Inter-Regular", size: 12))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        
                        Map(coordinateRegion: $mapRegion, interactionModes: .all, showsUserLocation: false, annotationItems: mapPins) { pin in
                            MapAnnotation(coordinate: pin.coordinate) {
                                VStack(spacing: 2) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(AppColors.primaryAction)
                                        .shadow(color: AppColors.cardShadow.opacity(0.6), radius: 6, x: 0, y: 4)
                                    Text("Drag map to refine")
                                        .font(.custom("Inter-Regular", size: 10))
                                        .foregroundStyle(AppColors.mutedText)
                                }
                            }
                        }
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay {
                            if pinnedCoordinate == nil {
                                VStack(spacing: 10) {
                                    Image(systemName: "location.viewfinder")
                                        .font(.system(size: 32, weight: .medium))
                                        .foregroundStyle(AppColors.mutedText)
                                    Text("We’ll auto-drop a pin from your photo.\nYou can also drag the map.")
                                        .multilineTextAlignment(.center)
                                        .font(.custom("Inter-Regular", size: 12))
                                        .foregroundStyle(AppColors.mutedText)
                                }
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: pinSignature)
                        .onChange(of: mapRegion.center.latitude) { _ in syncPinToMapCenter() }
                        .onChange(of: mapRegion.center.longitude) { _ in syncPinToMapCenter() }
                        
                        HStack(spacing: 12) {
                            Button {
                                handleUseMyLocationTap()
                            } label: {
                                Label("Use my location", systemImage: "location.fill")
                                    .padding(.horizontal, 12)
                            }

                            Spacer()

                            Button {
                                pinnedCoordinate = nil
                                locationOrigin = .none
                                locationMessage = "Pin cleared — drag the map or pick a photo"
                            } label: {
                                Label("Clear pin", systemImage: "xmark.circle")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                            }
                            .foregroundStyle(AppColors.mutedText)
                        }
                        .font(.custom("Inter-Regular", size: 12))
                    }

                    Divider()
                        
                    DescriptionEditor(text: $descriptionText)
                        .frame(minHeight: 60)
                }
                .padding(18)
                .frame(width: cardWidth)
                .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: AppColors.cardShadow.opacity(0.6), radius: 10, x: 0, y: 6)
                
                
                
                HStack(alignment: .center, spacing: 12) {
                    Button {
                        Task { await postCat() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: store.isPosting ? "arrow.up.circle.dashed" : "paperplane.fill")
                            Text(store.isPosting ? "Uploading..." : "Post")
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(AppColors.primaryAction)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(!canPost)
                }
            }
        }
        .padding(.vertical, 16)
        .background(AppColors.background)
        .onAppear {
            locationManager.startUpdating()
        }
        .onChange(of: selectedPhotoData) { data in
            guard let data else { return }
            if let coordinate = extractLocation(from: data) {
                setPinnedCoordinate(coordinate, origin: .photo)
                locationMessage = "Found a pin inside your photo’s EXIF"
            } else {
                if locationManager.isAuthorized {
                    locationManager.startUpdating()
                    locationMessage = "No EXIF found — using your current location"
                } else {
                    locationMessage = "No EXIF location found — drag to place a pin"
                }
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            if locationManager.isAuthorized && pinnedCoordinate == nil {
                locationManager.startUpdating()
            } else if status == .denied || status == .restricted {
                locationMessage = "Enable location to auto-drop a pin"
            }
        }
        .onReceive(locationManager.$coordinate.compactMap { $0 }) { coordinate in
            if pinnedCoordinate == nil || locationOrigin == .device {
                setPinnedCoordinate(coordinate, origin: .device)
                if locationOrigin != .photo {
                    locationMessage = "Using your current location"
                }
            }
        }
        .overlay {
            if showAllTagsOverlay {
                TagOverlayView(
                    selectedTags: $selectedTags,
                    showOverlay: $showAllTagsOverlay,
                    categorizedTags: categorizedTags
                )
            }
        }
        .alert("Location access needed", isPresented: $showLocationPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access to use your current location for pins.")
        }
    }
    
    // MARK: - Functions
    private func toggleTag(tag: String) {
        if selectedTags.contains(tag) { selectedTags.remove(tag) }
        else { selectedTags.insert(tag) }
    }
    
    private var canPost: Bool {
        !catName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedPhotoData != nil &&
        !store.isPosting
    }
    
    private var mapPins: [MapPin] {
        guard let coordinate = pinnedCoordinate else { return [] }
        return [MapPin(coordinate: coordinate)]
    }
    
    private var pinSignature: String {
        guard let coordinate = pinnedCoordinate else { return "none" }
        return "\(coordinate.latitude)-\(coordinate.longitude)"
    }
    
    private func setPinnedCoordinate(_ coordinate: CLLocationCoordinate2D, origin: LocationOrigin) {
        isProgrammaticRegionUpdate = true
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            pinnedCoordinate = coordinate
            mapRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
            locationOrigin = origin
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isProgrammaticRegionUpdate = false
        }
    }
    
    private func syncPinToMapCenter() {
        guard !isProgrammaticRegionUpdate else { return }
        pinnedCoordinate = mapRegion.center
        if locationOrigin != .photo {
            locationOrigin = .manual
            locationMessage = "Pin updated — it will be saved with your post"
        }
    }
    
    private func extractLocation(from data: Data) -> CLLocationCoordinate2D? {
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            let gpsDict = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any],
            let latitude = decimalDegrees(from: gpsDict[kCGImagePropertyGPSLatitude]),
            let longitude = decimalDegrees(from: gpsDict[kCGImagePropertyGPSLongitude])
        else { return nil }
        
        let latRef = (gpsDict[kCGImagePropertyGPSLatitudeRef] as? String)?.uppercased()
        let lonRef = (gpsDict[kCGImagePropertyGPSLongitudeRef] as? String)?.uppercased()
        let lat = (latRef == "S") ? -latitude : latitude
        let lon = (lonRef == "W") ? -longitude : longitude
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    private func decimalDegrees(from value: Any?) -> Double? {
        guard let value else { return nil }
        if let number = value as? NSNumber { return number.doubleValue }
        if let string = value as? String { return Double(string) }
        if let array = value as? [NSNumber], !array.isEmpty {
            let degrees = array[0].doubleValue
            let minutes = array.count > 1 ? array[1].doubleValue : 0
            let seconds = array.count > 2 ? array[2].doubleValue : 0
            return degrees + (minutes / 60) + (seconds / 3600)
        }
        if let dict = value as? [String: Any],
           let numerator = dict["numerator"] as? Double,
           let denominator = dict["denominator"] as? Double,
           denominator != 0 {
            return numerator / denominator
        }
        return nil
    }
    
    private func handleUseMyLocationTap() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationMessage = "Requesting location permission..."
            locationManager.requestPermission()
        case .denied, .restricted:
            showLocationPermissionAlert = true
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdating()
            if let coordinate = locationManager.coordinate {
                setPinnedCoordinate(coordinate, origin: .device)
            }
            locationMessage = "Using your current location"
        @unknown default:
            break
        }
    }
    
    private func postCat() async {
        guard let photoData = selectedPhotoData else { return }
        let base64 = photoData.base64EncodedString()

        let tags = Array(selectedTags)
        let location = pinnedCoordinate.map { CatLocation(latitude: $0.latitude, longitude: $0.longitude) }

        await store.postCat(
            name: catName,
            description: descriptionText,
            tags: tags,
            location: location,
            imageBase64: base64
        )

        if store.postingError == nil {
            catName = ""
            selectedPhotoData = nil
            selectedTags = []
            descriptionText = ""
            pinnedCoordinate = nil
            locationOrigin = .none
            locationMessage = "Add a pin or let us detect it"

            // Kick off a feed refresh and switch back to the Feed tab.
            Task { await store.refresh() }
            await MainActor.run {
                onPostSuccess?()
            }
        }
    }
}

// MARK: - Supporting Types
private struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

private enum LocationOrigin {
    case none, photo, device, manual
    
    var label: String {
        switch self {
        case .none: return ""
        case .photo: return "From photo EXIF"
        case .device: return "From your location"
        case .manual: return "Adjusted by you"
        }
    }
}

#Preview {
    PostView()
}
