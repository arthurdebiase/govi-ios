import SwiftUI

public struct AgentAvatarView: View {
    public let title: String
    public let avatarType: AgentAvatarType?
    public let colors: AgentColors?
    public let initials: String?
    public let isOnline: Bool?
    public let size: CGFloat
    
    public init(
        title: String,
        avatarType: AgentAvatarType? = .default,
        colors: AgentColors? = .default,
        initials: String? = nil,
        isOnline: Bool? = nil,
        size: CGFloat = 48
    ) {
        self.title = title
        self.avatarType = avatarType
        self.colors = colors
        self.initials = initials
        self.isOnline = isOnline
        self.size = size
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let initials = initials, !initials.isEmpty {
                // Human Attendant Avatar
                Circle()
                    .fill(Color(UIColor.secondarySystemFill))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(initials)
                            .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(UIColor.label))
                    )
            } else {
                // AI Agent Circular Avatar using official govi.svg
                GoviAvatarView(size: size)
            }
            
            // Online status indicator badge
            if let isOnline = isOnline, isOnline {
                Circle()
                    .fill(Color(UIColor.systemGreen))
                    .frame(width: size * 0.28, height: size * 0.28)
                    .overlay(
                        Circle()
                            .stroke(Color(UIColor.systemBackground), lineWidth: 2)
                    )
            }
        }
    }
}
