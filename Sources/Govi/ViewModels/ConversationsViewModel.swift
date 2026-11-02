import Foundation
import SwiftUI

@MainActor
@Observable
public final class ConversationsViewModel {
    public var conversations: [Conversation] = []
    public var agents: [GovBrAgent] = GovBrAgent.defaultAgents
    public var savedContacts: [CivicContact] = CivicContact.defaultContacts
    public var pendingRequests: [ConversationRequest] = []
    public var selectedFilter: ConversationPartnerType = .all
    public var searchText: String = ""
    public var selectedConversationId: String?
    
    public init() {
        self.conversations = Self.loadDefaultConversations()
        self.pendingRequests = [
            ConversationRequest(
                id: "req-beatriz",
                senderDisplayName: "Dra. Beatriz Mendes",
                senderAccountLevel: .ouro,
                senderInitials: "BM",
                senderMatrixId: "@beatriz.mendes:inss.gov.br",
                timestamp: "Há 5 minutos",
                introMessage: "Olá! Sou perita médica federal e gostaria de validar sua documentação para perícia presencial."
            )
        ]
    }
    
    public var pinnedConversations: [Conversation] {
        filteredConversations.filter { $0.isPinned }
    }
    
    public var unpinnedConversations: [Conversation] {
        filteredConversations.filter { !$0.isPinned }
    }
    
    public var filteredConversations: [Conversation] {
        conversations.filter { conv in
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .agent:
                matchesFilter = conv.type == "agent"
            case .person:
                matchesFilter = conv.type == "person"
            }
            
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                let term = searchText.lowercased()
                let titleMatch = conv.title.localizedCaseInsensitiveContains(term)
                let nameMatch = conv.displayName.localizedCaseInsensitiveContains(term)
                let messageMatch = conv.messages.contains { $0.content.localizedCaseInsensitiveContains(term) }
                matchesSearch = titleMatch || nameMatch || messageMatch
            }
            
            return matchesFilter && matchesSearch
        }
    }
    
    public func togglePin(for conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].isPinned.toggle()
            HapticManager.shared.impact(.medium)
        }
    }
    
    public func toggleMute(for conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index].isMuted.toggle()
            HapticManager.shared.selection()
        }
    }
    
    private var chatViewModels: [String: ChatViewModel] = [:]
    
    public func chatViewModel(for conversationId: String, userProfile: UserProfile) -> ChatViewModel? {
        guard let conv = conversations.first(where: { $0.id == conversationId }) else {
            return nil
        }
        if let existing = chatViewModels[conversationId] {
            existing.userProfile = userProfile
            return existing
        }
        let agent = agents.first(where: { $0.id == conv.agentId }) ?? GovBrAgent.defaultAgents[0]
        let vm = ChatViewModel(
            conversation: conv,
            agent: agent,
            userProfile: userProfile
        ) { [weak self] updated in
            self?.updateConversation(updated)
        }
        chatViewModels[conversationId] = vm
        return vm
    }
    
    public func updateConversation(_ updated: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == updated.id }) {
            conversations[index] = updated
        }
    }
    
    public func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        chatViewModels.removeValue(forKey: conversation.id)
        HapticManager.shared.notification(.warning)
    }
    
    public func acceptConversationRequest(
        _ request: ConversationRequest,
        permissions: SelectiveDisclosurePermissions
    ) -> Conversation {
        let now = Date()
        let newConv = Conversation(
            id: "conv-\(UUID().uuidString.prefix(8))",
            type: "person",
            title: "Atendimento Perícia Médica",
            personName: request.senderDisplayName,
            personRole: "Perita Médica Federal • INSS",
            personInitials: request.senderInitials,
            personOnline: true,
            matrixRoomId: "!pericia_\(UUID().uuidString.prefix(6)):inss.gov.br",
            matrixPartnerId: request.senderMatrixId,
            isE2EEEncrypted: true,
            isCrossSigningVerified: true,
            homeserverDomain: "inss.gov.br",
            messages: [
                Message(
                    role: .assistant,
                    content: "Olá! Recebi seu aceite seguro. Você autorizou o compartilhamento dos seguintes dados cívicos:\n\n• **Nome:** \(permissions.shareFullName ? "Nome Completo" : "Pseudônimo")\n• **Autenticação:** Conta Ouro gov.br ✅\n\(permissions.shareMaskedCpf ? "• **CPF:** Compartilhado\n" : "")\nComo posso orientar seu processo hoje?",
                    timestamp: "Agora"
                )
            ],
            createdAt: now,
            updatedAt: now
        )
        conversations.insert(newConv, at: 0)
        pendingRequests.removeAll { $0.id == request.id }
        HapticManager.shared.notification(.success)
        return newConv
    }
    
    public func declineConversationRequest(_ request: ConversationRequest) {
        pendingRequests.removeAll { $0.id == request.id }
        HapticManager.shared.notification(.warning)
    }
    
    public func markAllAsRead() {
        for index in conversations.indices {
            conversations[index].unreadCount = 0
        }
        HapticManager.shared.notification(.success)
    }
    
    public func startConversationWithContact(_ contact: CivicContact) -> Conversation {
        // If conversation already exists with this contact's matrixId, return it
        if let existingIndex = conversations.firstIndex(where: { $0.matrixPartnerId == contact.matrixId }) {
            return conversations[existingIndex]
        }
        
        let now = Date()
        let newConv = Conversation(
            id: "conv-\(UUID().uuidString.prefix(8))",
            type: "person",
            title: contact.name,
            personName: contact.name,
            personRole: "\(contact.role) • \(contact.department)",
            personInitials: contact.initials,
            personOnline: contact.isOnline,
            matrixRoomId: "!direct_\(UUID().uuidString.prefix(6)):gov.br",
            matrixPartnerId: contact.matrixId,
            isE2EEEncrypted: true,
            isCrossSigningVerified: true,
            homeserverDomain: "gov.br",
            messages: [
                Message(
                    role: .assistant,
                    content: "Olá! Conversa iniciada com \(contact.name) com criptografia ponta a ponta e verificação oficial gov.br.",
                    timestamp: "Agora"
                )
            ],
            createdAt: now,
            updatedAt: now
        )
        conversations.insert(newConv, at: 0)
        HapticManager.shared.impact(.light)
        return newConv
    }
    
    public func createNewConversation(with agent: GovBrAgent) -> Conversation {
        let newConv = Conversation(
            id: "conv-\(UUID().uuidString.prefix(8))",
            agentId: agent.id,
            type: "agent",
            title: "Nova conversa com \(agent.name)",
            agentName: agent.name,
            agentColors: agent.colors,
            matrixRoomId: "!agent_\(agent.id)_\(UUID().uuidString.prefix(6)):gov.br",
            matrixPartnerId: "@\(agent.id):ia.gov.br",
            isE2EEEncrypted: true,
            isCrossSigningVerified: true,
            homeserverDomain: "ia.gov.br",
            messages: [
                Message(
                    role: .assistant,
                    content: "Olá! Sou o **\(agent.name)** do Govi. Como posso ajudar com os serviços públicos hoje?",
                    suggestedActions: ["Consultar serviços", "Emitir documentos", "Ver orientações de tela"]
                )
            ]
        )
        conversations.insert(newConv, at: 0)
        HapticManager.shared.impact(.light)
        return newConv
    }
    
    public func startConversationFromScannedQR(_ scannedPayload: String) -> Conversation {
        let trimmed = scannedPayload.trimmingCharacters(in: .whitespacesAndNewlines)
        var resolvedName = "Cidadão Verificado gov.br"
        var resolvedMatrixId = "@cidadao.\(UUID().uuidString.prefix(4).lowercased()):gov.br"
        var resolvedRole = "Cidadão Conectado via QR Code • Conta Ouro gov.br"
        
        if let url = URL(string: trimmed), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let nameParam = components.queryItems?.first(where: { $0.name == "name" })?.value, !nameParam.isEmpty {
                resolvedName = nameParam
            } else if let inviteCode = url.pathComponents.last, !inviteCode.isEmpty, inviteCode != "/" {
                resolvedName = "Cidadão (\(inviteCode.uppercased()))"
            }
            if let mxidParam = components.queryItems?.first(where: { $0.name == "mxid" })?.value, !mxidParam.isEmpty {
                resolvedMatrixId = mxidParam
            }
            if let levelParam = components.queryItems?.first(where: { $0.name == "level" })?.value, !levelParam.isEmpty {
                resolvedRole = "Conexão QR Segura • Conta \(levelParam.capitalized) gov.br"
            }
        } else if trimmed.hasPrefix("@") {
            resolvedMatrixId = trimmed
            let localpart = trimmed.dropFirst().split(separator: ":").first.map(String.init) ?? "cidadao"
            resolvedName = localpart.replacingOccurrences(of: ".", with: " ").capitalized
        } else if !trimmed.isEmpty {
            resolvedName = trimmed
        }
        
        if let existing = conversations.first(where: { $0.matrixPartnerId == resolvedMatrixId }) {
            return existing
        }
        
        let words = resolvedName.split(separator: " ")
        let initials: String
        if words.count >= 2 {
            initials = "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        } else {
            initials = String(resolvedName.prefix(2)).uppercased()
        }
        
        let now = Date()
        let newConv = Conversation(
            id: "conv-\(UUID().uuidString.prefix(8))",
            type: "person",
            title: resolvedName,
            personName: resolvedName,
            personRole: resolvedRole,
            personInitials: initials,
            personOnline: true,
            matrixRoomId: "!qr_\(UUID().uuidString.prefix(6)):gov.br",
            matrixPartnerId: resolvedMatrixId,
            isE2EEEncrypted: true,
            isCrossSigningVerified: true,
            homeserverDomain: "gov.br",
            messages: [
                Message(
                    role: .assistant,
                    content: "🔒 Conexão estabelecida via leitura de QR Code com **\(resolvedName)**. Criptografia ponta a ponta Matrix (Olm/Megolm) ativa.",
                    timestamp: "Agora"
                )
            ],
            createdAt: now,
            updatedAt: now
        )
        conversations.insert(newConv, at: 0)
        HapticManager.shared.notification(.success)
        return newConv
    }
    
    private static func loadDefaultConversations() -> [Conversation] {
        let now = Date()
        
        let cndCard = ActionCard(
            id: "card-cnd-initial",
            type: .documentReady,
            title: "Certidão Negativa de Débitos Federais (CND)",
            subtitle: "Situação: REGULAR • Validade até 28/04/2027",
            status: .success,
            data: [
                "contribuinte": "Arthur Debiase",
                "documento": "123.842.198-00",
                "situacao": "NADA CONSTA / REGULAR",
                "codigoControle": "O1ET.D290.GLQW.4VGH",
                "validade": "28/04/2027"
            ],
            actions: [
                ActionCardButton(label: "Visualizar Certidão (PDF)", action: "VIEW_DOCUMENT", variant: "primary"),
                ActionCardButton(label: "Copiar Código", action: "COPY_CODE", variant: "secondary", payloadText: "O1ET.D290.GLQW.4VGH")
            ]
        )
        
        let ipvaCard = ActionCard(
            id: "card-ipva-initial",
            type: .vehicleReport,
            title: "Veículo • Placa BRA2E19",
            subtitle: "Renavam: 00987654321 • Detran/SP",
            status: .warning,
            data: [
                "placa": "BRA2E19",
                "modelo": "HYUNDAI HB20 1.0M COMFORT",
                "totalDebitos": "R$ 1.580,50",
                "ipvaValor": "R$ 1.420,50",
                "licenciamentoValor": "R$ 160,00"
            ],
            actions: [
                ActionCardButton(
                    label: "Pagar IPVA via Pix",
                    action: "PAY_IPVA_PIX",
                    variant: "primary",
                    payloadText: "00020101021226650014br.gov.bcb.pix0122ipva.sp@fazenda.gov.br0217IPVA 2026 BRA2E1952040000530398654071420.505802BR5913SEFAZ SP IPVA6009SAO PAULO62140510GOVI8110256304C97C"
                )
            ]
        )
        
        let dasCard = ActionCard(
            id: "card-das-initial",
            type: .pixPayment,
            title: "Guia DAS-MEI • 10/2026",
            subtitle: "CNPJ: 48.291.834/0001-92 • Vencimento: 20/11/2026",
            status: .warning,
            data: [
                "tipo": "DAS-MEI",
                "valorFormatado": "R$ 75,60",
                "vencimento": "20/11/2026",
                "pixCopiaECola": "00020101021226780014br.gov.bcb.pix0137receitafederal@simplesnacional.gov.br0215DAS MEI 10/2026520400005303986540575.605802BR5922SIMPLES NACIONAL PGMEI6008BRASILIA62140510GOVI6681326304A94E"
            ],
            actions: [
                ActionCardButton(
                    label: "Copiar Pix Copia e Cola",
                    action: "COPY_PIX",
                    variant: "primary",
                    payloadText: "00020101021226780014br.gov.bcb.pix0137receitafederal@simplesnacional.gov.br0215DAS MEI 10/2026520400005303986540575.605802BR5922SIMPLES NACIONAL PGMEI6008BRASILIA62140510GOVI6681326304A94E"
                )
            ]
        )
        
        return [
            Conversation(
                id: "conv-das-mei",
                agentId: "agent-mei-fiscal",
                type: "agent",
                title: "Emissão de Guia DAS-MEI",
                agentName: "MEI & Tributos",
                agentColors: AgentColors(background: "#059669", semiCircle: "#34D399", circle: "#FBBF24", stripe: "#064E3B"),
                matrixRoomId: "!das_mei:receita.gov.br",
                matrixPartnerId: "@mei:fazenda.gov.br",
                homeserverDomain: "receita.gov.br",
                isPinned: true,
                unreadCount: 1,
                messages: [
                    Message(role: .user, content: "Quero emitir minha guia do DAS do MEI com Pix", timestamp: "10:14"),
                    Message(
                        role: .assistant,
                        content: "Localizei a sua guia do **DAS-MEI** para o CNPJ **48.291.834/0001-92**.\n\n• **Valor:** R$ 75,60\n• **Vencimento:** 20/11/2026\n\nVocê pode efetuar o pagamento instantâneo via **Pix** abaixo:",
                        screens: [
                            ScreenItem(id: 501, name: "Emissão no PGMEI", flow: "DAS-MEI", order: 1, imageUrl: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&auto=format&fit=crop&q=80", altText: "Tela de competência no PGMEI")
                        ],
                        suggestedActions: ["Copiar Pix do DAS", "Como declarar o faturamento anual?", "Emitir Certidão de MEI"],
                        actionCard: dasCard,
                        timestamp: "10:14"
                    )
                ],
                createdAt: now,
                updatedAt: now
            ),
            Conversation(
                id: "conv-person-camila",
                type: "person",
                title: "Malha Fina IRPF",
                personName: "Dra. Camila Mendes",
                personRole: "Auditora-Fiscal • Receita Federal",
                personInitials: "CM",
                personOnline: true,
                matrixRoomId: "!malha_fina_irpf:receita.gov.br",
                matrixPartnerId: "@camila.mendes:receita.gov.br",
                homeserverDomain: "receita.gov.br",
                isPinned: true,
                messages: [
                    Message(role: .user, content: "Boa tarde Dra. Camila, recebi um aviso sobre comprovação de despesa médica na minha declaração.", timestamp: "11:42"),
                    Message(
                        role: .assistant,
                        content: "Boa tarde Arthur! Analisei o recibo médico anexado pelo portal e-CAC. Os comprovantes atenderam aos requisitos e a pendência na malha foi baixada com sucesso. Sua restituição foi reencaminhada para o próximo lote de pagamento residual.",
                        suggestedActions: ["Agradecer atendimento", "Consultar lote da restituição"],
                        timestamp: "11:45"
                    )
                ],
                createdAt: now.addingTimeInterval(-1800),
                updatedAt: now.addingTimeInterval(-1800)
            ),
            Conversation(
                id: "conv-cnd-federal",
                agentId: "agent-mei-fiscal",
                type: "agent",
                title: "Certidão Negativa de Débitos",
                agentName: "Govi (Padrão)",
                agentColors: .default,
                matrixRoomId: "!cnd_federal:receita.gov.br",
                matrixPartnerId: "@govi:ia.gov.br",
                homeserverDomain: "receita.gov.br",
                messages: [
                    Message(role: .user, content: "Emitir minha certidão negativa de débitos federais", timestamp: "Ontem"),
                    Message(
                        role: .assistant,
                        content: "Sua **Certidão Negativa de Débitos Federais (CND)** foi emitida com sucesso!\n\n• **Situação:** ✅ **REGULAR** (Sem pendências ativas)\n• **Validade:** 28/04/2027\n• **Código de Controle:** `O1ET.D290.GLQW.4VGH`\n\nVocê pode visualizar ou baixar o documento oficial abaixo:",
                        suggestedActions: ["Visualizar Certidão (PDF)", "Copiar Código de Autenticidade"],
                        actionCard: cndCard,
                        timestamp: "Ontem"
                    )
                ],
                createdAt: now.addingTimeInterval(-86400),
                updatedAt: now.addingTimeInterval(-86400)
            ),
            Conversation(
                id: "conv-veiculo-ipva",
                agentId: "agent-transito",
                type: "agent",
                title: "Débitos e IPVA Placa BRA2E19",
                agentName: "Trânsito & Veículos",
                agentColors: AgentColors(background: "#0284C7", semiCircle: "#38BDF8", circle: "#0F172A", stripe: "#F8FAFC"),
                matrixRoomId: "!veiculo_ipva:detran.sp.gov.br",
                matrixPartnerId: "@transito:detran.sp.gov.br",
                homeserverDomain: "detran.sp.gov.br",
                messages: [
                    Message(role: .user, content: "Consultar débitos e IPVA da placa BRA2E19", timestamp: "28 Out"),
                    Message(
                        role: .assistant,
                        content: "Consultei o veículo de placa **BRA2E19** junto ao **Detran**:\n\n• **Modelo:** HYUNDAI HB20 1.0M COMFORT\n• **Multas ativas:** Nenhuma infração pendente ✅\n• **IPVA 2026:** R$ 1.420,50\n• **Taxa de Licenciamento:** R$ 160,00",
                        suggestedActions: ["Pagar IPVA via Pix", "Como emitir o CRLV Digital?", "Consultar pontuação da CNH"],
                        actionCard: ipvaCard,
                        timestamp: "28 Out"
                    )
                ],
                createdAt: now.addingTimeInterval(-172800),
                updatedAt: now.addingTimeInterval(-172800)
            ),
            Conversation(
                id: "conv-person-marcos",
                type: "person",
                title: "Agendamento de Perícia Presencial",
                personName: "Marcos Oliveira",
                personRole: "Analista de Benefícios • INSS",
                personInitials: "MO",
                personOnline: true,
                matrixRoomId: "!pericia_inss:inss.gov.br",
                matrixPartnerId: "@marcos.oliveira:inss.gov.br",
                homeserverDomain: "inss.gov.br",
                messages: [
                    Message(role: .user, content: "Olá Marcos, preciso reagendar minha perícia médica presencial para o turno da manhã.", timestamp: "27 Out"),
                    Message(
                        role: .assistant,
                        content: "Olá Arthur! Verifiquei a disponibilidade na agência Central e consegui transferir seu atendimento para o dia 12 às 09:15. O comprovante já está atualizado no seu Meu INSS.",
                        suggestedActions: ["Ver comprovante de agendamento", "Quais documentos levar?"],
                        timestamp: "27 Out"
                    )
                ],
                createdAt: now.addingTimeInterval(-259200),
                updatedAt: now.addingTimeInterval(-259200)
            )
        ]
    }
}
