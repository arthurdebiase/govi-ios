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

public struct FloatingTabBarView: View {
    @Binding public var selectedTab: GoviTab
    public let onSearchTapped: () -> Void
    
    public init(selectedTab: Binding<GoviTab>, onSearchTapped: @escaping () -> Void) {
        self._selectedTab = selectedTab
        self.onSearchTapped = onSearchTapped
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            // Main Tab Bar Capsule
            HStack(spacing: 4) {
                ForEach(GoviTab.allCases) { tab in
                    Button(action: {
                        HapticManager.shared.selection()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 18, weight: selectedTab == tab ? .bold : .medium))
                                .foregroundStyle(selectedTab == tab ? Color(UIColor.systemBlue) : Color(UIColor.label).opacity(0.85))
                            
                            Text(tab.title)
                                .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundStyle(selectedTab == tab ? Color(UIColor.systemBlue) : Color(UIColor.secondaryLabel))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            selectedTab == tab
                            ? Color(UIColor.secondarySystemFill).opacity(0.8)
                            : Color.clear
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 58)
            .background(.ultraThinMaterial)
            .background(Color(UIColor.secondarySystemGroupedBackground).opacity(0.65))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 14, x: 0, y: 6)
            
            // Separate Floating Circular Search Button (Apple Style)
            Button(action: {
                HapticManager.shared.impact(.light)
                onSearchTapped()
            }) {
                Circle()
                    .fill(.ultraThinMaterial)
                    .background(Color(UIColor.secondarySystemGroupedBackground).opacity(0.65))
                    .clipShape(Circle())
                    .frame(width: 58, height: 58)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.8)
                    )
                    .overlay(
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(UIColor.label))
                    )
                    .shadow(color: Color.black.opacity(0.16), radius: 14, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Buscar no gov.br")
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
