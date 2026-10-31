import SwiftUI

public struct ContactDetailsSheet: View {
    public let conversation: Conversation
    public let agent: GovBrAgent
    public let onEditAgent: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(
        conversation: Conversation,
        agent: GovBrAgent,
        onEditAgent: @escaping () -> Void
    ) {
        self.conversation = conversation
        self.agent = agent
        self.onEditAgent = onEditAgent
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // Header Profile Section
                Section {
                    VStack(spacing: 12) {
                        AgentAvatarView(
                            title: conversation.displayName,
                            avatarType: conversation.type == "person" ? nil : agent.avatarType,
                            colors: conversation.agentColors ?? agent.colors,
                            initials: conversation.personInitials,
                            isOnline: conversation.personOnline,
                            size: 80
                        )
                        
                        VStack(spacing: 4) {
                            Text(conversation.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(UIColor.label))
                                .multilineTextAlignment(.center)
                            
                            Text(conversation.displaySubtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Action buttons row (Apple Messages Contact style)
                        HStack(spacing: 24) {
                            ActionButton(title: "Mensagem", systemImage: "message.fill") {
                                dismiss()
                            }
                            
                            ActionButton(title: "Compartilhar", systemImage: "square.and.arrow.up.fill") {
                                HapticManager.shared.impact(.light)
                            }
                            
                            ActionButton(title: "Info Oficial", systemImage: "info.circle.fill") {
                                HapticManager.shared.impact(.light)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // Repartição & Autenticidade
                Section("Autenticidade & Segurança gov.br") {
                    HStack {
                        Label("Canal Oficial", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Color(UIColor.systemGreen))
                        Spacer()
                        Text("Verificado gov.br")
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                    
                    HStack {
                        Label("Nível Exigido", systemImage: "shield.checkered")
                            .foregroundStyle(Color(UIColor.systemBlue))
                        Spacer()
                        Text("Prata ou Ouro")
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                    
                    HStack {
                        Label("Criptografia", systemImage: "lock.fill")
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                        Spacer()
                        Text("Ponta a Ponta (Soberano)")
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                }
                
                // Capacidades e Permissões
                Section("Capacidades Habilitadas") {
                    ForEach(GovBrAgent.availableCapabilities) { cap in
                        HStack {
                            Label(cap.name, systemImage: cap.systemImage)
                            Spacer()
                            if agent.allowedCapabilities.contains(cap.id) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(UIColor.systemBlue))
                                    .fontWeight(.bold)
                            } else {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                            }
                        }
                    }
                }
                
                // Opções do Agente
                if conversation.type != "person" {
                    Section {
                        Button(action: {
                            dismiss()
                            onEditAgent()
                        }) {
                            Label("Personalizar Instruções do Agente", systemImage: "slider.horizontal.3")
                                .foregroundStyle(Color(UIColor.systemBlue))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Detalhes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(UIColor.systemBlue))
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
            }
        }
        .buttonStyle(.plain)
    }
}
