import SwiftUI

public struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
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
                    // Matrix Sovereign E2EE Header Notice
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(Color(UIColor.systemGreen))
                            Text("Criptografia de Ponta a Ponta Matrix • Olm/Megolm")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                        Text("Servidor soberano: \(viewModel.conversation.homeserverDomain) • Verificado com gov.br")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            // Leading: Botão de voltar e Pill com Avatar + Nome (alinhados à esquerda, sem subtítulo)
            ToolbarItem(placement: .topBarLeading) {
                HStack(spacing: 8) {
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(UIColor.label))
                            .frame(width: 36, height: 36)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Voltar")
                    
                    // Pill com Avatar e Nome
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
                                size: 28
                            )
                            
                            Text(viewModel.conversation.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(UIColor.label))
                                .lineLimit(1)
                            
                            if viewModel.conversation.isCrossSigningVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(UIColor.systemGreen))
                            }
                        }
                        .padding(.leading, 4)
                        .padding(.trailing, 12)
                        .padding(.vertical, 4)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Trailing: Ícone "..." preto sem círculo de borda
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    HapticManager.shared.impact(.light)
                    viewModel.isShowingContactDetails = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(UIColor.label))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Opções da Conversa")
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
