import SwiftUI

public struct MessageBubbleView: View {
    public let message: Message
    public let onSelectScreen: (ScreenItem) -> Void
    public let onActionCardButton: (ActionCardButton) -> Void
    
    public init(
        message: Message,
        onSelectScreen: @escaping (ScreenItem) -> Void,
        onActionCardButton: @escaping (ActionCardButton) -> Void
    ) {
        self.message = message
        self.onSelectScreen = onSelectScreen
        self.onActionCardButton = onActionCardButton
    }
    
    public var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 6) {
            // Text Bubble
            HStack {
                if message.role == .user {
                    Spacer(minLength: 44)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey(message.content))
                        .font(.body)
                        .foregroundStyle(message.role == .user ? Color.white : Color(UIColor.label))
                        .textSelection(.enabled)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(bubbleBackground)
                .clipShape(bubbleShape)
                
                if message.role == .assistant {
                    Spacer(minLength: 44)
                }
            }
            
            // Action Card (if any)
            if let card = message.actionCard {
                ActionCardView(card: card, onAction: onActionCardButton)
                    .padding(.top, 4)
                    .frame(maxWidth: 380, alignment: .leading)
            }
            
            // Screen Previews (Guias Visuais com Telas Reais)
            if let screens = message.screens, !screens.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Telas Oficiais do Aplicativo", systemImage: "photo.stack.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .padding(.horizontal, 4)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(screens) { screen in
                                Button(action: {
                                    HapticManager.shared.impact(.light)
                                    onSelectScreen(screen)
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        AsyncImage(url: URL(string: screen.displayUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 140, height: 220)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 140, height: 220)
                                                    .clipped()
                                            case .failure:
                                                VStack {
                                                    Image(systemName: "photo")
                                                        .font(.title2)
                                                        .foregroundStyle(Color(UIColor.secondaryLabel))
                                                    Text(screen.name)
                                                        .font(.caption2)
                                                        .foregroundStyle(Color(UIColor.secondaryLabel))
                                                }
                                                .frame(width: 140, height: 220)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .background(Color(UIColor.tertiarySystemFill))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color(UIColor.separator), lineWidth: 0.8)
                                        )
                                        
                                        Text(screen.name)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color(UIColor.label))
                                            .lineLimit(1)
                                            .frame(width: 140, alignment: .leading)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.top, 4)
            }
            
            // Timestamp
            Text(message.timestamp)
                .font(.caption2)
                .foregroundStyle(Color(UIColor.tertiaryLabel))
                .padding(.horizontal, 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 3)
    }
    
    private var bubbleBackground: Color {
        if message.role == .user {
            return Color(UIColor.systemBlue)
        } else {
            return Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var bubbleShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }
}
