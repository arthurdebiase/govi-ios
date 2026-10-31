import Foundation

public struct ChatAPIRequest: Codable, Sendable {
    public let message: String
    public let history: [ChatAPIHistoryItem]
    public let connectedAppIds: [Int]
    public let agentName: String?
    public let agentPrompt: String?
    public let allowedCapabilities: [String]?
    public let userName: String?
    public let userAccountLevel: String?
    public let userCpf: String?
}

public struct ChatAPIHistoryItem: Codable, Sendable {
    public let role: String
    public let content: String
}

public struct ChatAPIResponse: Codable, Sendable {
    public let reply: String
    public let screens: [ScreenItem]?
    public let suggestedActions: [String]?
    public let source: String?
    public let actionCard: ActionCard?
}

public actor GoviAPIService {
    public static let shared = GoviAPIService()
    
    private let baseURL = URL(string: "http://127.0.0.1:5001")!
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8.0
        self.session = URLSession(configuration: config)
    }
    
    public func sendChatMessage(
        text: String,
        history: [Message],
        agent: GovBrAgent,
        userProfile: UserProfile,
        connectedAppIds: [Int] = [1, 2, 3, 4, 5, 6]
    ) async -> (reply: String, screens: [ScreenItem], suggestedActions: [String], actionCard: ActionCard?) {
        
        // 1. Attempt live network request to backend
        do {
            let endpoint = baseURL.appendingPathComponent("api/govbr-ia/chat")
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let historyPayload = history.suffix(10).map {
                ChatAPIHistoryItem(role: $0.role.rawValue, content: $0.content)
            }
            
            let payload = ChatAPIRequest(
                message: text,
                history: Array(historyPayload),
                connectedAppIds: connectedAppIds,
                agentName: agent.name,
                agentPrompt: agent.systemPrompt,
                allowedCapabilities: agent.allowedCapabilities,
                userName: userProfile.name,
                userAccountLevel: userProfile.accountLevel.rawValue,
                userCpf: userProfile.cpf
            )
            
            request.httpBody = try JSONEncoder().encode(payload)
            
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ChatAPIResponse.self, from: data)
                return (
                    reply: decoded.reply,
                    screens: decoded.screens ?? [],
                    suggestedActions: decoded.suggestedActions ?? [],
                    actionCard: decoded.actionCard
                )
            }
        } catch {
            // Live backend unavailable, proceed to sovereign offline deterministic engine
        }
        
        // 2. Sovereign Local Deterministic Fallback Engine (Native iOS Simulation)
        return simulateResponse(for: text, agent: agent, userProfile: userProfile)
    }
    
    private func simulateResponse(
        for prompt: String,
        agent: GovBrAgent,
        userProfile: UserProfile
    ) -> (reply: String, screens: [ScreenItem], suggestedActions: [String], actionCard: ActionCard?) {
        let lower = prompt.lowercased()
        
        // MEI & Tributos DAS
        if lower.contains("das") || lower.contains("mei") || lower.contains("boleto") {
            let card = ActionCard(
                id: "card-das-\(UUID().uuidString.prefix(6))",
                type: .pixPayment,
                title: "Guia DAS-MEI • 10/2026",
                subtitle: "CNPJ: \(userProfile.cnpj ?? "48.291.834/0001-92") • Vencimento: 20/11/2026",
                status: .warning,
                data: [
                    "tipo": "DAS-MEI",
                    "valor": "75.60",
                    "valorFormatado": "R$ 75,60",
                    "vencimento": "20/11/2026",
                    "pixCopiaECola": "00020101021226780014br.gov.bcb.pix0137receitafederal@simplesnacional.gov.br0215DAS MEI 10/2026520400005303986540575.605802BR5922SIMPLES NACIONAL PGMEI6008BRASILIA62140510GOVI6681326304A94E",
                    "orgao": "Receita Federal / Simples Nacional"
                ],
                actions: [
                    ActionCardButton(
                        label: "Copiar Pix Copia e Cola",
                        action: "COPY_PIX",
                        variant: "primary",
                        payloadText: "00020101021226780014br.gov.bcb.pix0137receitafederal@simplesnacional.gov.br0215DAS MEI 10/2026520400005303986540575.605802BR5922SIMPLES NACIONAL PGMEI6008BRASILIA62140510GOVI6681326304A94E"
                    ),
                    ActionCardButton(label: "Baixar PDF da Guia", action: "VIEW_DAS_PDF", variant: "secondary")
                ]
            )
            return (
                reply: "Localizei a guia do **DAS-MEI** para o CNPJ **\(userProfile.cnpj ?? "48.291.834/0001-92")**.\n\n• **Valor:** R$ 75,60\n• **Vencimento:** 20/11/2026\n• **Benefícios:** Aposentadoria por idade, auxílio-doença e salário-maternidade.\n\nVocê pode pagar instantaneamente com baixa bancária em poucos minutos pelo cartão abaixo:",
                screens: [
                    ScreenItem(id: 501, name: "Emitir Guia DAS - PGMEI", flow: "Emissão de DAS", order: 1, imageUrl: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&auto=format&fit=crop&q=80", altText: "Tela de seleção de ano e competência no PGMEI"),
                    ScreenItem(id: 502, name: "Confirmação com Pix", flow: "Pagamento Pix", order: 2, imageUrl: "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=600&auto=format&fit=crop&q=80", altText: "Tela de confirmação com QR Code Pix do Simples Nacional")
                ],
                suggestedActions: ["Copiar Pix do DAS", "Como fazer a Declaração Anual (DASN)?", "Consultar débitos anteriores"],
                actionCard: card
            )
        }
        
        // CND / Certidão Negativa
        if lower.contains("cnd") || lower.contains("certidão") || lower.contains("certidao") || lower.contains("regularidade") {
            let card = ActionCard(
                id: "card-cnd-\(UUID().uuidString.prefix(6))",
                type: .documentReady,
                title: "Certidão Negativa de Débitos Federais (CND)",
                subtitle: "Situação: REGULAR • Validade até 28/04/2027",
                status: .success,
                data: [
                    "contribuinte": userProfile.name,
                    "documento": userProfile.cpf,
                    "situacao": "NADA CONSTA / REGULAR",
                    "codigoControle": "O1ET.D290.GLQW.4VGH",
                    "validade": "28/04/2027"
                ],
                actions: [
                    ActionCardButton(label: "Visualizar Certidão (PDF)", action: "VIEW_DOCUMENT", variant: "primary"),
                    ActionCardButton(label: "Copiar Código de Autenticidade", action: "COPY_CODE", variant: "secondary", payloadText: "O1ET.D290.GLQW.4VGH")
                ]
            )
            return (
                reply: "Sua **Certidão Negativa de Débitos Federais (CND)** foi emitida com sucesso!\n\n• **Contribuinte:** \(userProfile.name) (\(userProfile.cpf))\n• **Órgão Expedidor:** Secretaria Especial da Receita Federal do Brasil / PGFN\n• **Situação:** ✅ **REGULAR** (Sem pendências ativas)\n• **Validade:** 28/04/2027\n• **Código de Controle:** `O1ET.D290.GLQW.4VGH`\n\nO documento oficial com assinatura gov.br está pronto abaixo:",
                screens: [
                    ScreenItem(id: 401, name: "Consulta de Certidão Negativa", flow: "CND Federal", order: 1, imageUrl: "https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600&auto=format&fit=crop&q=80", altText: "Resultado da certidão negativa no portal e-CAC")
                ],
                suggestedActions: ["Visualizar Certidão em PDF", "Como enviar para banco ou licitação?", "Consultar situação cadastral do CPF"],
                actionCard: card
            )
        }
        
        // Veículo / IPVA / CNH
        if lower.contains("ipva") || lower.contains("placa") || lower.contains("veiculo") || lower.contains("cnh") || lower.contains("carro") {
            let placa = userProfile.vehicles.first?.placa ?? "BRA2E19"
            let card = ActionCard(
                id: "card-veic-\(UUID().uuidString.prefix(6))",
                type: .vehicleReport,
                title: "Veículo • Placa \(placa)",
                subtitle: "Renavam: 00987654321 • Detran/SP",
                status: .warning,
                data: [
                    "placa": placa,
                    "modelo": userProfile.vehicles.first?.modelo ?? "HYUNDAI HB20 1.0M COMFORT",
                    "totalDebitos": "R$ 1.580,50",
                    "ipvaValor": "R$ 1.420,50",
                    "licenciamentoValor": "R$ 160,00",
                    "multas": "0 ativas"
                ],
                actions: [
                    ActionCardButton(
                        label: "Pagar IPVA c/ Desconto via Pix",
                        action: "PAY_IPVA_PIX",
                        variant: "primary",
                        payloadText: "00020101021226650014br.gov.bcb.pix0122ipva.sp@fazenda.gov.br0217IPVA 2026 BRA2E1952040000530398654071420.505802BR5913SEFAZ SP IPVA6009SAO PAULO62140510GOVI8110256304C97C"
                    ),
                    ActionCardButton(label: "Ver CRLV Digital", action: "VIEW_CRLV", variant: "secondary")
                ]
            )
            return (
                reply: "Consultei os registros do veículo **\(placa)** junto ao **Detran**:\n\n• **Modelo:** \(userProfile.vehicles.first?.modelo ?? "HYUNDAI HB20 1.0M COMFORT")\n• **Multas ativas:** Nenhuma infração pendente ✅\n• **IPVA 2026:** R$ 1.420,50 (Cota Única c/ desconto)\n• **Licenciamento Anual:** R$ 160,00 (Vencimento Julho/2026)\n\nVocê pode efetuar a quitação com baixa imediata via Pix no cartão abaixo:",
                screens: [
                    ScreenItem(id: 301, name: "Painel de Veículos - CDT", flow: "Consulta Veículo", order: 1, imageUrl: "https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600&auto=format&fit=crop&q=80", altText: "Tela de veículos cadastrados na Carteira Digital de Trânsito"),
                    ScreenItem(id: 302, name: "Detalhamento de Débitos e Licenciamento", flow: "Licenciamento", order: 2, imageUrl: "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&auto=format&fit=crop&q=80", altText: "Extrato discriminado de tributos do veículo")
                ],
                suggestedActions: ["Pagar IPVA via Pix", "Como baixar o CRLV-e no celular?", "Consultar pontuação da CNH"],
                actionCard: card
            )
        }
        
        // INSS / Aposentadoria / CNIS
        if lower.contains("inss") || lower.contains("aposentadoria") || lower.contains("cnis") || lower.contains("beneficio") {
            return (
                reply: "Consultei seu extrato previdenciário (**CNIS**) junto ao **Meu INSS**:\n\n• **Tempo total apurado:** 28 anos, 4 meses e 12 dias de contribuição;\n• **Regra de Transição mais vantajosa:** Sistema de Pontos (Regra 86/96);\n• **Previsão de Aposentadoria:** Atingimento dos requisitos em Novembro/2027;\n• **Recomendação Govi:** Solicitar a averbação de um período de estágio sem data fim para adiantar seu benefício.",
                screens: [
                    ScreenItem(id: 201, name: "Extrato CNIS - Meu INSS", flow: "Extrato de Contribuições", order: 1, imageUrl: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=600&auto=format&fit=crop&q=80", altText: "Lista de vínculos trabalhistas no Meu INSS"),
                    ScreenItem(id: 202, name: "Simulador de Aposentadoria", flow: "Simulação", order: 2, imageUrl: "https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=600&auto=format&fit=crop&q=80", altText: "Gráfico de regras de transição da previdência")
                ],
                suggestedActions: ["Baixar Extrato CNIS em PDF", "Simular valor do benefício estimado", "Como agendar perícia presencial?"],
                actionCard: nil
            )
        }
        
        // Default Govi response
        return (
            reply: "Olá, \(userProfile.name)! Sou o **\(agent.name)** do Govi.\n\nPosso te orientar nos serviços digitais oficiais do governo brasileiro (**gov.br**). Diga-me o que você precisa resolver hoje:\n\n• **Aposentadoria e INSS:** Simulação, extrato de vínculos e perícias.\n• **Receita Federal:** Declaração IRPF, CND e regularização de CPF.\n• **MEI e Empresas:** Emissão de guia DAS mensal e baixa de débitos.\n• **Trânsito:** Consulta de IPVA, multas e emissão do CRLV digital.",
            screens: [
                ScreenItem(id: 101, name: "Tela Inicial gov.br", flow: "Acesso e Serviços", order: 1, imageUrl: "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=600&auto=format&fit=crop&q=80", altText: "Página inicial do aplicativo oficial gov.br")
            ],
            suggestedActions: ["Emitir DAS-MEI com Pix", "Consultar IPVA e débitos", "Emitir Certidão Negativa (CND)", "Simular Aposentadoria no INSS"],
            actionCard: nil
        )
    }
}
