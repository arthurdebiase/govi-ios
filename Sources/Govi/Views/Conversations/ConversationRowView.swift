import SwiftUI

public struct ConversationRowView: View {
    public let conversation: Conversation
    
    public init(conversation: Conversation) {
        self.conversation = conversation
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // Unread dot indicator (Apple Messages style)
            if conversation.unreadCount > 0 {
                Circle()
                    .fill(Color(UIColor.systemBlue))
                    .frame(width: 8, height: 8)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 8, height: 8)
            }
            
            // Avatar
            AgentAvatarView(
                title: conversation.displayName,
                avatarType: conversation.type == "person" ? nil : .default,
                colors: conversation.agentColors,
                initials: conversation.personInitials,
                isOnline: conversation.personOnline,
                size: 52
            )
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    HStack(spacing: 4) {
                        Text(conversation.displayName)
                            .font(.headline)
                            .foregroundStyle(Color(UIColor.label))
                            .lineLimit(1)
                        
                        if conversation.isCrossSigningVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(Color(UIColor.systemGreen))
                        }
                    }
                    
                    Spacer()
                    
                    Text(conversation.lastMessageTime)
                        .font(.subheadline)
                        .foregroundStyle(conversation.unreadCount > 0 ? Color(UIColor.systemBlue) : Color(UIColor.secondaryLabel))
                }
                
                HStack(alignment: .center, spacing: 6) {
                    Text(conversation.lastMessageText)
                        .font(.subheadline)
                        .foregroundStyle(conversation.unreadCount > 0 ? Color(UIColor.label) : Color(UIColor.secondaryLabel))
                        .fontWeight(conversation.unreadCount > 0 ? .medium : .regular)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if conversation.isE2EEEncrypted {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    
                    if conversation.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    
                    if conversation.isMuted {
                        Image(systemName: "bell.slash.fill")
                            .font(.caption2)
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
