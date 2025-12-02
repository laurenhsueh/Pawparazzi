import SwiftUI

struct UserView: View {
    @StateObject private var manager = SupabaseManager.shared
    
    let username: String = "CatLover"
    let profileImage: String = "person.circle.fill"
    let memberSince: String = "2024"
    let location: String = "Los Angeles, CA"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Account")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: profileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(AppColors.mutedText)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(username)
                            .font(.title2)
                            .bold()
                        
                        HStack(spacing: 16) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Member since \(memberSince)")
                            }
                            HStack {
                                Image(systemName: "location.fill")
                                Text(location)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // Collections
                ForEach(manager.userCollections.keys.sorted(), id: \.self) { collection in
                    VStack(alignment: .leading) {
                        Text(collection).font(.headline)
                        
                        if let photos = manager.userCollections[collection], !photos.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(photos, id: \.self) { urlString in
                                        if let url = URL(string: urlString) {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: 120, height: 120)
                                                    .clipped()
                                                    .cornerRadius(10)
                                            } placeholder: {
                                                Rectangle()
                                                    .fill(AppColors.secondarySystemBackground)
                                                    .frame(width: 120, height: 120)
                                                    .cornerRadius(10)
                                                    .overlay(ProgressView())
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("No photos yet")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}


#Preview {
    UserView()
}
