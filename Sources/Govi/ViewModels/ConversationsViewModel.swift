import Foundation
import SwiftUI

@MainActor
@Observable
public final class ConversationsViewModel {
    public var conversations: [Conversation] = []
    public var agents: [GovBrAgent] = GovBrAgent.defaultAgents
    public var selectedFilter: ConversationPartnerType = .all
    public var searchText: String = ""
    public var selectedConversationId: String?
    
    public init() {
        self.conversations = Self.loadDefaultConversations()
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
    
    public func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        HapticManager.shared.notification(.warning)
    }
    
    public func createNewConversation(with agent: GovBrAgent) -> Conversation {
        let newConv = Conversation(
            id: "conv-\(UUID().uuidString.prefix(8))",
            agentId: agent.id,
            type: "agent",
            title: "Nova conversa com \(agent.name)",
            agentName: agent.name,
            agentColors: agent.colors,
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
            ),
            Conversation(
                id: "conv-previdencia-aposentadoria",
                agentId: "agent-previdencia",
                type: "agent",
                title: "Simulação de Aposentadoria",
                agentName: "Previdência & Benefícios",
                agentColors: AgentColors(background: "#6D28D9", semiCircle: "#A78BFA", circle: "#F59E0B", stripe: "#2E1065"),
                messages: [
                    Message(role: .user, content: "Consulte meu tempo de contribuição e simule minha aposentadoria pelo INSS", timestamp: "25 Out"),
                    Message(
                        role: .assistant,
                        content: "Acessando o extrato previdenciário (CNIS) pelo Meu INSS.\n\n* **Tempo total apurado:** 28 anos, 4 meses e 12 dias;\n* **Regra mais vantajosa:** Sistema de Pontos (Regra 86/96);\n* **Estimativa de aposentadoria:** Novembro/2027.",
                        suggestedActions: ["Baixar Extrato CNIS em PDF", "Como agendar atendimento presencial?"],
                        timestamp: "25 Out"
                    )
                ],
                createdAt: now.addingTimeInterval(-345600),
                updatedAt: now.addingTimeInterval(-345600)
            )
        ]
    }
}
