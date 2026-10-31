import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
public final class ChatViewModel {
    public var conversation: Conversation
    public var agent: GovBrAgent
    public var userProfile: UserProfile
    public var inputText: String = ""
    public var isLoading: Bool = false
    public var bannerMessage: String?
    public var selectedScreenForDetail: ScreenItem?
    public var isShowingContactDetails: Bool = false
    public var isShowingAgentEditor: Bool = false
    
    private let apiService = GoviAPIService.shared
    
    public init(conversation: Conversation, agent: GovBrAgent, userProfile: UserProfile) {
        self.conversation = conversation
        self.agent = agent
        self.userProfile = userProfile
    }
    
    public func sendCurrentMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        sendPrompt(trimmed)
    }
    
    public func sendPrompt(_ text: String) {
        HapticManager.shared.impact(.medium)
        
        // Add user message
        let userMessage = Message(role: .user, content: text)
        conversation.messages.append(userMessage)
        conversation.updatedAt = Date()
        
        isLoading = true
        
        Task {
            let result = await apiService.sendChatMessage(
                text: text,
                history: conversation.messages,
                agent: agent,
                userProfile: userProfile
            )
            
            let assistantMessage = Message(
                role: .assistant,
                content: result.reply,
                screens: result.screens.isEmpty ? nil : result.screens,
                suggestedActions: result.suggestedActions.isEmpty ? nil : result.suggestedActions,
                actionCard: result.actionCard
            )
            
            conversation.messages.append(assistantMessage)
            conversation.updatedAt = Date()
            isLoading = false
            
            HapticManager.shared.notification(.success)
        }
    }
    
    public func handleActionCardButton(_ button: ActionCardButton) {
        HapticManager.shared.impact(.light)
        
        switch button.action {
        case "COPY_PIX", "COPY_CODE":
            if let payload = button.payloadText {
                UIPasteboard.general.string = payload
                showBanner("Copiado para a área de transferência!")
                HapticManager.shared.notification(.success)
            }
        case "PAY_IPVA_PIX":
            if let payload = button.payloadText {
                UIPasteboard.general.string = payload
                showBanner("Código Pix do IPVA copiado! Abra o app do seu banco para pagar.")
                HapticManager.shared.notification(.success)
            }
        case "VIEW_DOCUMENT", "VIEW_DAS_PDF", "VIEW_CRLV":
            showBanner("Abrindo visualização oficial do documento...")
            HapticManager.shared.impact(.medium)
        default:
            sendPrompt(button.label)
        }
    }
    
    public func showBanner(_ message: String) {
        bannerMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if bannerMessage == message {
                bannerMessage = nil
            }
        }
    }
}
