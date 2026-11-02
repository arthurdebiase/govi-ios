import SwiftUI

public struct NewConversationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ConversationsViewModel
    public let userProfile: UserProfile
    let onSelect: (Conversation) -> Void
    
    @State private var searchText: String = ""
    @State private var isShowingCreateAgentSheet: Bool = false
    @State private var isShowingInviteSheet: Bool = false
    @State private var newAgentDraft = GovBrAgent(
        id: "custom-\(UUID().uuidString.prefix(6))",
        name: "",
        description: "",
        avatarType: .custom,
        systemPrompt: "Você é um agente virtual gov.br personalizado."
    )
    
    public init(
        viewModel: ConversationsViewModel,
        userProfile: UserProfile = UserProfile(),
        onSelect: @escaping (Conversation) -> Void
    ) {
        self.viewModel = viewModel
        self.userProfile = userProfile
        self.onSelect = onSelect
    }
    
    private var filteredAgents: [GovBrAgent] {
        if searchText.isEmpty {
            return viewModel.agents
        }
        return viewModel.agents.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredContacts: [CivicContact] {
        if searchText.isEmpty {
            return viewModel.savedContacts
        }
        return viewModel.savedContacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // Section 0: Quick Action Options (Apple Style)
                if searchText.isEmpty {
                    Section {
                        // 1. Nova conversa (Abre Convite QR Code Seguro)
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            isShowingInviteSheet = true
                        }) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color(UIColor.systemBlue))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Image(systemName: "bubble.left.and.bubble.right.fill")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(Color.white)
                                    )
                                
                                Text("Nova conversa")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                        
                        // 2. Criar novo agente
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            newAgentDraft = GovBrAgent(
                                id: "custom-\(UUID().uuidString.prefix(6))",
                                name: "",
                                description: "",
                                avatarType: .custom,
                                systemPrompt: ""
                            )
                            isShowingCreateAgentSheet = true
                        }) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color(UIColor.systemGreen))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(Color.white)
                                    )
                                
                                Text("Criar novo agente")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                        
                        // 3. Novo Grupo
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            let groupConv = Conversation(
                                id: "conv-group-\(UUID().uuidString.prefix(6))",
                                type: "group",
                                title: "Novo Grupo Cívico",
                                personName: "Grupo Cívico",
                                personInitials: "GP",
                                personOnline: true,
                                matrixRoomId: "!group_\(UUID().uuidString.prefix(6)):gov.br",
                                matrixPartnerId: "@group:gov.br",
                                isE2EEEncrypted: true,
                                isCrossSigningVerified: true,
                                homeserverDomain: "gov.br",
                                messages: [
                                    Message(
                                        role: .assistant,
                                        content: "Grupo seguro criado com criptografia ponta a ponta e governança gov.br.",
                                        timestamp: "Agora"
                                    )
                                ],
                                createdAt: Date(),
                                updatedAt: Date()
                            )
                            viewModel.conversations.insert(groupConv, at: 0)
                            dismiss()
                            onSelect(groupConv)
                        }) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color(UIColor.systemIndigo))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(Color.white)
                                    )
                                
                                Text("Novo Grupo")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Section 1: Agentes Virtuais (Apenas Avatar govi.svg e Nome)
                Section("Agentes Virtuais (IA gov.br)") {
                    ForEach(filteredAgents) { agent in
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            let conv = viewModel.createNewConversation(with: agent)
                            dismiss()
                            onSelect(conv)
                        }) {
                            HStack(spacing: 14) {
                                // Avatar oficial govi.svg
                                GoviAvatarView(size: 38)
                                
                                Text(agent.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Section 2: Contatos Conectados (Apenas Avatar e Nome)
                Section("Contatos e Cidadãos Conectados") {
                    ForEach(filteredContacts) { contact in
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            let conv = viewModel.startConversationWithContact(contact)
                            dismiss()
                            onSelect(conv)
                        }) {
                            HStack(spacing: 14) {
                                AgentAvatarView(
                                    title: contact.name,
                                    initials: contact.initials,
                                    isOnline: contact.isOnline,
                                    size: 38
                                )
                                
                                Text(contact.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Buscar agente ou contato")
            .navigationTitle("Nova Conversa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateAgentSheet) {
                AgentEditorSheet(agent: $newAgentDraft) { savedAgent in
                    viewModel.agents.append(savedAgent)
                    let conv = viewModel.createNewConversation(with: savedAgent)
                    dismiss()
                    onSelect(conv)
                }
            }
            .sheet(isPresented: $isShowingInviteSheet) {
                InviteSheet(userProfile: userProfile) { acceptedPayload in
                    let conv = viewModel.startConversationFromScannedQR(acceptedPayload)
                    dismiss()
                    onSelect(conv)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
