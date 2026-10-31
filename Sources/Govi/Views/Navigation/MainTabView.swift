import SwiftUI

public enum GoviTab: Int, CaseIterable, Identifiable {
    case chats = 0
    case connect = 1
    case profile = 2
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .chats: return "Chats"
        case .connect: return "Conectar"
        case .profile: return "Perfil"
        }
    }
    
    public var iconName: String {
        switch self {
        case .chats: return "bubble.left.and.bubble.right.fill"
        case .connect: return "link"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

public struct MainTabView: View {
    @Bindable public var conversationsViewModel: ConversationsViewModel
    @Bindable public var profileViewModel: ProfileViewModel
    @Bindable public var marketplaceViewModel: MarketplaceViewModel
    
    @State private var selectedTab: GoviTab = .chats
    
    public init(
        conversationsViewModel: ConversationsViewModel,
        profileViewModel: ProfileViewModel,
        marketplaceViewModel: MarketplaceViewModel
    ) {
        self.conversationsViewModel = conversationsViewModel
        self.profileViewModel = profileViewModel
        self.marketplaceViewModel = marketplaceViewModel
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            ConversationListView(
                viewModel: conversationsViewModel,
                profileViewModel: profileViewModel,
                marketplaceViewModel: marketplaceViewModel
            )
            .tabItem {
                Label(GoviTab.chats.title, systemImage: GoviTab.chats.iconName)
            }
            .tag(GoviTab.chats)
            
            MarketplaceTabView(viewModel: marketplaceViewModel)
                .tabItem {
                    Label(GoviTab.connect.title, systemImage: GoviTab.connect.iconName)
                }
                .tag(GoviTab.connect)
            
            ProfileTabView(viewModel: profileViewModel)
                .tabItem {
                    Label(GoviTab.profile.title, systemImage: GoviTab.profile.iconName)
                }
                .tag(GoviTab.profile)
        }
    }
}
