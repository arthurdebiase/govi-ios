import SwiftUI

public struct MainTabView: View {
    @Bindable public var conversationsViewModel: ConversationsViewModel
    @Bindable public var profileViewModel: ProfileViewModel
    @Bindable public var marketplaceViewModel: MarketplaceViewModel
    
    @State private var selectedTab: GoviTab = .messages
    @State private var isShowingSearchSheet: Bool = false
    
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
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .messages:
                    ConversationListView(
                        viewModel: conversationsViewModel,
                        profileViewModel: profileViewModel,
                        marketplaceViewModel: marketplaceViewModel
                    )
                case .services:
                    MarketplaceTabView(viewModel: marketplaceViewModel)
                case .screens:
                    ScreensCatalogView()
                case .profile:
                    ProfileTabView(viewModel: profileViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Modern Apple Floating Tab Bar with Search Button
            FloatingTabBarView(selectedTab: $selectedTab) {
                isShowingSearchSheet = true
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $isShowingSearchSheet) {
            GlobalSearchView(marketplaceViewModel: marketplaceViewModel)
        }
    }
}
