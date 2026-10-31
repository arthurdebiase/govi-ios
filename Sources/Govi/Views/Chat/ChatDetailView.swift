import SwiftUI

public struct ChatDetailView: View {
    @Bindable public var viewModel: ChatViewModel
    @State private var scrollProxy: ScrollViewProxy?
    
    public init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Floating Banner Notification (like "Pix Copiado!")
            if let banner = viewModel.bannerMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(UIColor.systemGreen))
                    Text(banner)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(UIColor.label))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.08), radius: 6, y: 3)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: viewModel.bannerMessage)
            }
            
            // Messages Scroll View
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.conversation.messages) { message in
                            MessageBubbleView(
                                message: message,
                                onSelectScreen: { screen in
                                    viewModel.selectedScreenForDetail = screen
                                },
                                onActionCardButton: { button in
                                    viewModel.handleActionCardButton(button)
                                }
                            )
                            .id(message.id)
                        }
                        
                        // Typing / Loading indicator
                        if viewModel.isLoading {
                            HStack {
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Govi está consultando a base oficial...")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(UIColor.secondaryLabel))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(UIColor.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .id("loading-indicator")
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onAppear {
                    self.scrollProxy = proxy
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.conversation.messages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.isLoading) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            // Contextual Suggested Action Chips
            if let lastMessage = viewModel.conversation.messages.last,
               let suggestions = lastMessage.suggestedActions,
               !suggestions.isEmpty,
               !viewModel.isLoading {
                SuggestedActionsView(suggestions: suggestions) { suggestion in
                    viewModel.sendPrompt(suggestion)
                }
                .padding(.bottom, 4)
            }
            
            // Apple Messages Input Bar
            ChatInputBarView(
                text: $viewModel.inputText,
                isLoading: viewModel.isLoading,
                onSend: {
                    viewModel.sendCurrentMessage()
                },
                onQuickAction: { prompt in
                    viewModel.sendPrompt(prompt)
                }
            )
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Centered Title with Avatar and Tap Gesture (Apple Messages style)
            ToolbarItem(placement: .principal) {
                Button(action: {
                    HapticManager.shared.impact(.light)
                    viewModel.isShowingContactDetails = true
                }) {
                    HStack(spacing: 8) {
                        AgentAvatarView(
                            title: viewModel.conversation.displayName,
                            avatarType: viewModel.conversation.type == "person" ? nil : viewModel.agent.avatarType,
                            colors: viewModel.conversation.agentColors ?? viewModel.agent.colors,
                            initials: viewModel.conversation.personInitials,
                            isOnline: viewModel.conversation.personOnline,
                            size: 32
                        )
                        
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 4) {
                                Text(viewModel.conversation.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(UIColor.label))
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                            }
                            
                            Text(viewModel.conversation.displaySubtitle)
                                .font(.caption2)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .lineLimit(1)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            
            // Info Button on Trailing
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    HapticManager.shared.impact(.light)
                    viewModel.isShowingContactDetails = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.body)
                }
                .accessibilityLabel("Detalhes do Contato")
            }
        }
        // Sheets
        .sheet(isPresented: $viewModel.isShowingContactDetails) {
            ContactDetailsSheet(
                conversation: viewModel.conversation,
                agent: viewModel.agent,
                onEditAgent: {
                    viewModel.isShowingAgentEditor = true
                }
            )
        }
        .sheet(isPresented: $viewModel.isShowingAgentEditor) {
            AgentEditorSheet(agent: $viewModel.agent) { updated in
                viewModel.conversation.agentName = updated.name
            }
        }
        .sheet(item: $viewModel.selectedScreenForDetail) { screen in
            ScreenGallerySheet(screens: [screen])
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            withAnimation(.easeOut(duration: 0.25)) {
                if viewModel.isLoading {
                    proxy.scrollTo("loading-indicator", anchor: .bottom)
                } else if let last = viewModel.conversation.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}
