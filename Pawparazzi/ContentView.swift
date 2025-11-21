import SwiftUI

struct ContentView: View {
    @State private var selectedTab: String = "home"
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Main content
            ZStack {
                switch selectedTab {
                case "home":
                    HomeView()
                case "explore":
                    ExploreView()
                case "post":
                    PostView()
                case "friends":
                    FriendsView()
                case "user":
                    UserView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Bottom Nav Bar
            HStack {
                NavBarButton(icon: "house", title: "Home", isSelected: selectedTab == "home") {
                    selectedTab = "home"
                }
                
                NavBarButton(icon: "magnifyingglass", title: "Explore", isSelected: selectedTab == "explore") {
                    selectedTab = "explore"
                }
                
                NavBarButton(icon: "plus.circle", title: "Post", isSelected: selectedTab == "post") {
                    selectedTab = "post"
                }
                
                NavBarButton(icon: "person.2", title: "Friends", isSelected: selectedTab == "friends") {
                    selectedTab = "friends"
                }
                
                NavBarButton(icon: "person.crop.circle", title: "User", isSelected: selectedTab == "user") {
                    selectedTab = "user"
                }
            }
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground).shadow(radius: 2))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - NavBarButton
struct NavBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(title)
                    .font(.footnote)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
