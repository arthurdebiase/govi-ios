import SwiftUI

public struct ConversationListView: View {
    @Bindable public var viewModel: ConversationsViewModel
    @Bindable public var profileViewModel: ProfileViewModel
    @Bindable public var marketplaceViewModel: MarketplaceViewModel
    
    @State private var isShowingProfileSheet: Bool = false
    @State private var isShowingMarketplaceSheet: Bool = false
    @State private var isShowingInviteSheet: Bool = false
    @State private var selectedRequestForConsent: ConversationRequest?
    @State private var navigationPath = NavigationPath()
    
    public init(
        viewModel: ConversationsViewModel,
        profileViewModel: ProfileViewModel,
        marketplaceViewModel: MarketplaceViewModel
    ) {
        self.viewModel = viewModel
        self.profileViewModel = profileViewModel
        self.marketplaceViewModel = marketplaceViewModel
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // Pending Conversation Requests (Handshake & Consent Flow)
                if !viewModel.pendingRequests.isEmpty && viewModel.searchText.isEmpty {
                    Section("Solicitações de Conversa") {
                        ForEach(viewModel.pendingRequests) { req in
                            Button(action: {
                                HapticManager.shared.impact(.medium)
                                selectedRequestForConsent = req
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(UIColor.systemGreen).opacity(0.15))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Text(req.senderInitials)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(Color(UIColor.systemGreen))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 4) {
                                            Text(req.senderDisplayName)
                                                .font(.headline)
                                                .foregroundStyle(Color(UIColor.label))
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.caption)
                                                .foregroundStyle(Color(UIColor.systemGreen))
                                        }
                                        
                                        Text(req.introMessage)
                                            .font(.caption)
                                            .foregroundStyle(Color(UIColor.secondaryLabel))
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Revisar")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color(UIColor.systemBlue))
                                        .foregroundStyle(Color.white)
                                        .clipShape(Capsule())
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Filter Picker Section (Apple Messages style)
                Section {
                    Picker("Filtro", selection: $viewModel.selectedFilter) {
                        ForEach(ConversationPartnerType.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                
                // Pinned Conversations Section
                if !viewModel.pinnedConversations.isEmpty && viewModel.searchText.isEmpty {
                    Section("Fixadas") {
                        ForEach(viewModel.pinnedConversations) { conv in
                            NavigationLink(value: conv.id) {
                                ConversationRowView(conversation: conv)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteConversation(conv)
                                } label: {
                                    Label("Apagar", systemImage: "trash")
                                }
                                
                                Button {
                                    viewModel.toggleMute(for: conv)
                                } label: {
                                    Label(conv.isMuted ? "Ativar Som" : "Silenciar", systemImage: conv.isMuted ? "bell" : "bell.slash")
                                }
                                .tint(Color(UIColor.systemIndigo))
                                
                                Button {
                                    viewModel.togglePin(for: conv)
                                } label: {
                                    Label("Desafixar", systemImage: "pin.slash")
                                }
                                .tint(Color(UIColor.systemOrange))
                            }
                        }
                    }
                }
                
                // Regular / All Conversations Section
                Section(viewModel.pinnedConversations.isEmpty || !viewModel.searchText.isEmpty ? "Conversas" : "Todas as Conversas") {
                    if viewModel.filteredConversations.isEmpty {
                        ContentUnavailableView(
                            "Nenhuma conversa encontrada",
                            systemImage: "bubble.left.and.bubble.right",
                            description: Text("Tente buscar por termos como DAS, CND, IPVA ou aposentadoria.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.searchText.isEmpty ? viewModel.unpinnedConversations : viewModel.filteredConversations) { conv in
                            NavigationLink(value: conv.id) {
                                ConversationRowView(conversation: conv)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteConversation(conv)
                                } label: {
                                    Label("Apagar", systemImage: "trash")
                                }
                                
                                Button {
                                    viewModel.toggleMute(for: conv)
                                } label: {
                                    Label(conv.isMuted ? "Ativar Som" : "Silenciar", systemImage: conv.isMuted ? "bell" : "bell.slash")
                                }
                                .tint(Color(UIColor.systemIndigo))
                                
                                Button {
                                    viewModel.togglePin(for: conv)
                                } label: {
                                    Label(conv.isPinned ? "Desafixar" : "Fixar", systemImage: "pin")
                                }
                                .tint(Color(UIColor.systemOrange))
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $viewModel.searchText, prompt: "Buscar em mensagens e serviços gov.br")
            .navigationTitle("Mensagens")
            .navigationDestination(for: String.self) { convId in
                if let convIndex = viewModel.conversations.firstIndex(where: { $0.id == convId }) {
                    let conv = viewModel.conversations[convIndex]
                    let agent = viewModel.agents.first(where: { $0.id == conv.agentId }) ?? GovBrAgent.defaultAgents[0]
                    let chatVM = ChatViewModel(
                        conversation: conv,
                        agent: agent,
                        userProfile: profileViewModel.profile
                    )
                    ChatDetailView(viewModel: chatVM)
                }
            }
            .toolbar {
                // Leading: Editar
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                // Trailing: QR Code Convite, Marketplace, Profile, New Chat Menu
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // QR Code / Convite Efêmero 60s
                    Button {
                        HapticManager.shared.impact(.light)
                        isShowingInviteSheet = true
                    } label: {
                        Image(systemName: "qrcode")
                    }
                    .accessibilityLabel("Meu Convite Seguro")
                    
                    // Marketplace gov.br
                    Button {
                        HapticManager.shared.impact(.light)
                        isShowingMarketplaceSheet = true
                    } label: {
                        Image(systemName: "square.grid.2x2")
                    }
                    .accessibilityLabel("Serviços gov.br")
                    
                    // Profile gov.br
                    Button {
                        HapticManager.shared.impact(.light)
                        isShowingProfileSheet = true
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            Image(systemName: "person.crop.circle")
                            Circle()
                                .fill(profileViewModel.profile.accountLevel == .ouro ? Color(UIColor.systemYellow) : Color(UIColor.systemGray))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .accessibilityLabel("Perfil e Conta gov.br")
                    
                    // New Message Menu
                    Menu {
                        Section("Iniciar com Agente Virtual (IA)") {
                            ForEach(viewModel.agents) { agent in
                                Button {
                                    let newConv = viewModel.createNewConversation(with: agent)
                                    navigationPath.append(newConv.id)
                                } label: {
                                    Label(agent.name, systemImage: agent.avatarType.systemImageName)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.body)
                    }
                    .accessibilityLabel("Nova Conversa")
                }
            }
            // Sheets
            .sheet(isPresented: $isShowingProfileSheet) {
                ProfileSheet(viewModel: profileViewModel)
            }
            .sheet(isPresented: $isShowingMarketplaceSheet) {
                MarketplaceSheet(viewModel: marketplaceViewModel)
            }
            .sheet(isPresented: $isShowingInviteSheet) {
                InviteSheet(userProfile: profileViewModel.profile)
            }
            .sheet(item: $selectedRequestForConsent) { req in
                ConversationConsentSheet(
                    request: req,
                    userProfile: profileViewModel.profile,
                    onAccept: { perms in
                        let newConv = viewModel.acceptConversationRequest(req, permissions: perms)
                        navigationPath.append(newConv.id)
                    },
                    onDecline: {
                        viewModel.declineConversationRequest(req)
                    }
                )
            }
        }
    }
}
