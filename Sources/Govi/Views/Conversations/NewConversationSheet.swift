import SwiftUI

public struct NewConversationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: ConversationsViewModel
    let onSelect: (Conversation) -> Void
    
    @State private var searchText: String = ""
    
    public init(
        viewModel: ConversationsViewModel,
        onSelect: @escaping (Conversation) -> Void
    ) {
        self.viewModel = viewModel
        self.onSelect = onSelect
    }
    
    private var filteredAgents: [GovBrAgent] {
        if searchText.isEmpty {
            return viewModel.agents
        }
        return viewModel.agents.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredContacts: [CivicContact] {
        if searchText.isEmpty {
            return viewModel.savedContacts
        }
        return viewModel.savedContacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.role.localizedCaseInsensitiveContains(searchText) ||
            $0.department.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // Section 1: Official AI Agents
                Section("Agentes Virtuais (IA gov.br)") {
                    ForEach(filteredAgents) { agent in
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            let conv = viewModel.createNewConversation(with: agent)
                            dismiss()
                            onSelect(conv)
                        }) {
                            HStack(spacing: 12) {
                                AgentAvatarView(
                                    title: agent.name,
                                    avatarType: agent.avatarType,
                                    colors: agent.colors,
                                    size: 44
                                )
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 4) {
                                        Text(agent.name)
                                            .font(.headline)
                                            .foregroundStyle(Color(UIColor.label))
                                        
                                        Image(systemName: "sparkles")
                                            .font(.caption2)
                                            .foregroundStyle(Color(UIColor.systemGreen))
                                    }
                                    
                                    Text(agent.description)
                                        .font(.subheadline)
                                        .foregroundStyle(Color(UIColor.secondaryLabel))
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Section 2: Verified Civic Contacts & Human Attendants
                Section("Contatos e Cidadãos Conectados") {
                    ForEach(filteredContacts) { contact in
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            let conv = viewModel.startConversationWithContact(contact)
                            dismiss()
                            onSelect(conv)
                        }) {
                            HStack(spacing: 12) {
                                AgentAvatarView(
                                    title: contact.name,
                                    initials: contact.initials,
                                    isOnline: contact.isOnline,
                                    size: 44
                                )
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 4) {
                                        Text(contact.name)
                                            .font(.headline)
                                            .foregroundStyle(Color(UIColor.label))
                                        
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.caption)
                                            .foregroundStyle(contact.accountLevel == .ouro ? Color(UIColor.systemYellow) : Color(UIColor.systemGreen))
                                    }
                                    
                                    Text("\(contact.role) • \(contact.department)")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(UIColor.secondaryLabel))
                                        .lineLimit(1)
                                    
                                    Text(contact.matrixId)
                                        .font(.caption2)
                                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Buscar agente ou contato")
            .navigationTitle("Nova Conversa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
