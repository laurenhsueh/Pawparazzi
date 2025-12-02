import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        Group {
            if sessionManager.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: sessionManager.isAuthenticated)
    }
}

private struct MainTabView: View {
    @State private var selectedTab: String = "feed"

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Main content
            ZStack {
                switch selectedTab {
                case "feed": FeedView()
                case "explore": ExploreView()
                case "post": PostView()
                case "friends": FriendsView()
                case "user": UserView()
                default: FeedView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Bottom Nav Bar
            ZStack(alignment: .top) {
                Color(UIColor.systemBackground).shadow(radius: 2)
                
                GeometryReader { geo in
                    let tabWidth = geo.size.width / 5
                    
                    // Red pill indicator
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.accent)
                        .frame(width: tabWidth * 0.6, height: 4)
                        .offset(x: tabOffset(selectedTab: selectedTab, tabWidth: tabWidth), y: 0)
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                
                HStack(spacing: 0) {
                    NavBarButton(icon: "FeedIcon", title: "Feed", isSelected: selectedTab == "feed") {
                        withAnimation { selectedTab = "feed" }
                    }
                    
                    NavBarButton(icon: "SearchIcon", title: "Explore", isSelected: selectedTab == "explore") {
                        withAnimation { selectedTab = "explore" }
                    }
                    
                    NavBarButton(icon: "PostIcon", title: "Post", isSelected: selectedTab == "post") {
                        withAnimation { selectedTab = "post" }
                    }
                    
                    NavBarButton(icon: "FriendsIcon", title: "Friends", isSelected: selectedTab == "friends") {
                        withAnimation { selectedTab = "friends" }
                    }
                    
                    NavBarButton(icon: "UserIcon", title: "User", isSelected: selectedTab == "user") {
                        withAnimation { selectedTab = "user" }
                    }
                }
                .padding(.top, 16)
            }
            .frame(height: 80)
        }
        .background(AppColors.background)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - Calculate pill offset
    private func tabOffset(selectedTab: String, tabWidth: CGFloat) -> CGFloat {
        switch selectedTab {
        case "feed": return tabWidth * 0 + (tabWidth * 0.2)
        case "explore": return tabWidth * 1 + (tabWidth * 0.2)
        case "post": return tabWidth * 2 + (tabWidth * 0.2)
        case "friends": return tabWidth * 3 + (tabWidth * 0.2)
        case "user": return tabWidth * 4 + (tabWidth * 0.2)
        default: return 0
        }
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
                Image(icon)
                    .renderingMode(icon == "UserIcon" ? .original : .template)
                    .foregroundStyle(
                        icon == "UserIcon"
                        ? .primary
                        : (isSelected ? AppColors.accent : AppColors.mutedText)
                    )

                Text(title)
                    .font(.custom("Inter-Regular", size: 10))
                    .foregroundStyle(
                        isSelected ? AppColors.accent : AppColors.mutedText
                    )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionManager(api: PawparazziAPI()))
}
