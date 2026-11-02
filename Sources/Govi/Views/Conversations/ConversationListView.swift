import SwiftUI

public struct ConversationListView: View {
    @Bindable public var viewModel: ConversationsViewModel
    @Bindable public var profileViewModel: ProfileViewModel
    @Bindable public var marketplaceViewModel: MarketplaceViewModel
    
    @State private var isShowingInviteSheet: Bool = false
    @State private var isShowingNewConversationSheet: Bool = false
    @State private var selectedRequestForConsent: ConversationRequest?
    @State private var navigationPath = NavigationPath()
    @State private var isEditMode: EditMode = .inactive
    @State private var selectedConversationIds = Set<String>()
    
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
            Group {
                if isEditMode == .active {
                    List(selection: $selectedConversationIds) {
                        conversationsListSections
                    }
                } else {
                    List {
                        conversationsListSections
                    }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, $isEditMode)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Buscar em conversas e serviços gov.br")
            .navigationTitle("Chats")
            .navigationDestination(for: String.self) { convId in
                if let chatVM = viewModel.chatViewModel(for: convId, userProfile: profileViewModel.profile) {
                    ChatDetailView(viewModel: chatVM)
                }
            }
            .toolbar {
                // Leading: "..." Menu or "OK" when editing
                ToolbarItem(placement: .topBarLeading) {
                    if isEditMode == .active {
                        Button("OK") {
                            withAnimation {
                                isEditMode = .inactive
                            }
                        }
                        .fontWeight(.semibold)
                    } else {
                        Menu {
                            Button {
                                withAnimation {
                                    isEditMode = .active
                                }
                            } label: {
                                Label("Selecionar conversas", systemImage: "checkmark.circle")
                            }
                            
                            Button {
                                viewModel.markAllAsRead()
                            } label: {
                                Label("Marcar tudo como Lido", systemImage: "envelope.open")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.body)
                        }
                        .accessibilityLabel("Opções de conversa")
                    }
                }
                
                // Trailing: Botão Primário Criar "+"
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.light)
                        isShowingNewConversationSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemBlue))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Nova Conversa")
                }
            }
            // Sheets
            .sheet(isPresented: $isShowingNewConversationSheet) {
                NewConversationSheet(
                    viewModel: viewModel,
                    userProfile: profileViewModel.profile
                ) { newConv in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        navigationPath.append(newConv.id)
                    }
                }
            }
            .sheet(item: $selectedRequestForConsent) { req in
                ConversationConsentSheet(
                    request: req,
                    userProfile: profileViewModel.profile,
                    onAccept: { perms in
                        let newConv = viewModel.acceptConversationRequest(req, permissions: perms)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            navigationPath.append(newConv.id)
                        }
                    },
                    onDecline: {
                        viewModel.declineConversationRequest(req)
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private var conversationsListSections: some View {
        // Pending Conversation Requests (Handshake & Consent Flow)
        if !viewModel.pendingRequests.isEmpty && viewModel.searchText.isEmpty && isEditMode != .active {
            Section("Solicitações de Conversa") {
                ForEach(viewModel.pendingRequests) { req in
                    Button {
                        HapticManager.shared.impact(.medium)
                        selectedRequestForConsent = req
                    } label: {
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
        if isEditMode != .active {
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
        }
        
        // Pinned Conversations Section
        if !viewModel.pinnedConversations.isEmpty && viewModel.searchText.isEmpty {
            Section("Fixadas") {
                ForEach(viewModel.pinnedConversations) { conv in
                    if isEditMode == .active {
                        ConversationRowView(conversation: conv)
                            .tag(conv.id)
                    } else {
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
                    if isEditMode == .active {
                        ConversationRowView(conversation: conv)
                            .tag(conv.id)
                    } else {
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
    }
}
