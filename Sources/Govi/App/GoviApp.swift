import SwiftUI

@main
public struct GoviApp: App {
    @State private var conversationsViewModel = ConversationsViewModel()
    @State private var profileViewModel = ProfileViewModel()
    @State private var marketplaceViewModel = MarketplaceViewModel()
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainTabView(
                conversationsViewModel: conversationsViewModel,
                profileViewModel: profileViewModel,
                marketplaceViewModel: marketplaceViewModel
            )
            .tint(Color(UIColor.systemBlue))
        }
    }
}
