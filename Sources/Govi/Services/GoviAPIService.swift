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
        return await simulateResponse(for: text, agent: agent, userProfile: userProfile)
    }
    
    private func simulateResponse(
        for prompt: String,
        agent: GovBrAgent,
        userProfile: UserProfile
    ) async -> (reply: String, screens: [ScreenItem], suggestedActions: [String], actionCard: ActionCard?) {
        let lower = prompt.lowercased()
        
        // ---------------------------------------------------------
        // AÇÕES NÃO INTEGRADAS -> Registrar na Tabela de Integrações
        // ---------------------------------------------------------
        
        // 1. Agendamento Presencial / Perícia Médica no INSS ou SUS
        if lower.contains("agendar") || lower.contains("agendamento") || lower.contains("pericia presencial") || lower.contains("perícia presencial") || lower.contains("consulta medica") || lower.contains("consulta médica") {
            let title = "Agendamento Presencial de Perícia / Atendimento"
            let agency = "INSS / Ministério da Saúde"
            let category = "Previdência & Benefícios"
            
            await MainActor.run {
                IntegrationsStore.shared.recordIntegration(
                    title: title,
                    agency: agency,
                    category: category,
                    userPrompt: prompt
                )
            }
            
            return (
                reply: "Ainda não consigo realizar esse agendamento presencial diretamente por aqui.\n\n📋 **Já anotei sua solicitação na Tabela de Integrações para o Futuro!** Você pode acompanhar os pedidos registrados na aba **Conectar**.\n\nEnquanto essa integração está em desenvolvimento, você pode agendar pelo telefone **135** ou pelo portal oficial **meu.inss.gov.br**.",
                screens: [],
                suggestedActions: ["Ver Tabela de Integrações", "Simular Aposentadoria", "Extrato CNIS"],
                actionCard: nil
            )
        }
        
        // 2. Emissão de Passaporte (Polícia Federal)
        if lower.contains("passaporte") || lower.contains("policia federal") || lower.contains("polícia federal") || lower.contains("visto") {
            let title = "Emissão de Passaporte e Pagamento de GRU"
            let agency = "Polícia Federal"
            let category = "Cidadania & Viagem"
            
            await MainActor.run {
                IntegrationsStore.shared.recordIntegration(
                    title: title,
                    agency: agency,
                    category: category,
                    userPrompt: prompt
                )
            }
            
            return (
                reply: "Ainda não possuo integração para emissão de passaporte diretamente no app.\n\n📋 **Já registrei essa demanda na nossa Tabela de Integrações para o Futuro** (na aba **Conectar**) para ser priorizada!\n\nPara solicitar hoje, preencha o formulário eletrônico e emita a taxa GRU diretamente no portal **gov.br/pf**.",
                screens: [],
                suggestedActions: ["Ver Tabela de Integrações", "Emitir Certidão (CND)", "Consultar CPF"],
                actionCard: nil
            )
        }
        
        // 3. Serviços Eleitorais / Título de Eleitor (TSE)
        if lower.contains("titulo") || lower.contains("título") || lower.contains("eleitor") || lower.contains("eleitoral") || lower.contains("votar") || lower.contains("justificativa") {
            let title = "Serviços Eleitorais e Transferência de Título"
            let agency = "Tribunal Superior Eleitoral (TSE)"
            let category = "Cidadania & Justiça"
            
            await MainActor.run {
                IntegrationsStore.shared.recordIntegration(
                    title: title,
                    agency: agency,
                    category: category,
                    userPrompt: prompt
                )
            }
            
            return (
                reply: "Ainda não consigo realizar operações de título de eleitor diretamente por aqui.\n\n📋 **Anotei sua solicitação na Tabela de Integrações para o Futuro** (disponível na aba **Conectar**)!\n\nEnquanto isso, você pode regularizar ou transferir seu título através do sistema **Título Net** no portal **tse.jus.br**.",
                screens: [],
                suggestedActions: ["Ver Tabela de Integrações", "Consultar outros serviços"],
                actionCard: nil
            )
        }
        
        // 4. Transações Bancárias Privadas / Empréstimos / Pix Privado
        if lower.contains("transferir") || lower.contains("emprestimo") || lower.contains("empréstimo") || lower.contains("banco") || (lower.contains("pix") && (lower.contains("amigo") || lower.contains("conta") || lower.contains("reais") || lower.contains("r$"))) {
            let title = "Integração Bancária e Empréstimos (Open Finance)"
            let agency = "Sistema Financeiro Nacional (Banco Central)"
            let category = "Serviços Financeiros"
            
            await MainActor.run {
                IntegrationsStore.shared.recordIntegration(
                    title: title,
                    agency: agency,
                    category: category,
                    userPrompt: prompt
                )
            }
            
            return (
                reply: "O Govi processa guias oficiais governamentais (como DAS e IPVA), mas ainda não realiza transferências bancárias particulares nem contratação de empréstimos.\n\n📋 **Já anotei essa funcionalidade na nossa Tabela de Integrações para o Futuro!**\n\nPara essas operações, utilize diretamente o aplicativo do seu banco ou internet banking.",
                screens: [],
                suggestedActions: ["Ver Tabela de Integrações", "Pagar DAS-MEI", "Pagar IPVA"],
                actionCard: nil
            )
        }
        
        // 5. Recurso de Multas de Trânsito / Defesa Prévia
        if lower.contains("recurso") || lower.contains("cancelar multa") || lower.contains("contestar") || lower.contains("pontos cnh") {
            let title = "Recurso e Defesa de Multas de Trânsito"
            let agency = "Detran / JARI / Cetran"
            let category = "Trânsito & Mobilidade"
            
            await MainActor.run {
                IntegrationsStore.shared.recordIntegration(
                    title: title,
                    agency: agency,
                    category: category,
                    userPrompt: prompt
                )
            }
            
            return (
                reply: "Ainda não tenho suporte para protocolar recursos ou defesas de autuações de trânsito diretamente.\n\n📋 **Adicionei essa solicitação à Tabela de Integrações para o Futuro** na aba **Conectar**!\n\nVocê pode protocolar o recurso administrativo pelo portal online do **Detran** do seu estado ou junto à **JARI**.",
                screens: [],
                suggestedActions: ["Ver Tabela de Integrações", "Consultar IPVA e débitos", "Ver CRLV Digital"],
                actionCard: nil
            )
        }
        
        // 6. Serviços Municipais (IPTU / Alvará / Prefeitura)
        if lower.contains("iptu") || lower.contains("prefeitura") || lower.contains("alvara") || lower.contains("alvará") || lower.contains("lixo") {
            let title = "Integração Municipal: IPTU e Alvarás"
            let agency = "Prefeitura Municipal"
            let category = "Serviços Municipais"
            
            await MainActor.run {
                IntegrationsStore.shared.recordIntegration(
                    title: title,
                    agency: agency,
                    category: category,
                    userPrompt: prompt
                )
            }
            
            return (
                reply: "Serviços municipais como IPTU e alvarás dependem da integração específica da sua cidade.\n\n📋 **Já registrei essa demanda na nossa Tabela de Integrações para o Futuro** para expandirmos com as prefeituras!\n\nPor favor, consulte o portal oficial da Prefeitura do seu município para emitir essas guias.",
                screens: [],
                suggestedActions: ["Ver Tabela de Integrações", "Emitir Certidão Federal (CND)"],
                actionCard: nil
            )
        }
        
        // 7. Qualquer outra ação imperativa não suportada
        if lower.hasPrefix("fazer ") || lower.hasPrefix("cancelar ") || lower.hasPrefix("comprar ") || lower.hasPrefix("assinar ") || lower.hasPrefix("pedir ") || lower.hasPrefix("solicitar ") {
            let actionName = String(prompt.prefix(40))
            let title = "Ação Solicitada: \(actionName)"
            let agency = "Órgão Público Responsável"
            let category = "Integração Futura"
            
            await MainActor.run {
                IntegrationsStore.shared.recordIntegration(
                    title: title,
                    agency: agency,
                    category: category,
                    userPrompt: prompt
                )
            }
            
            return (
                reply: "Ainda não tenho integração direta para completar essa ação (**\(actionName)**).\n\n📋 **Já anotei sua solicitação na Tabela de Integrações para o Futuro** (disponível na aba **Conectar**) para priorizarmos no roadmap do Govi!\n\nEnquanto isso, você pode verificar o procedimento diretamente no portal oficial do **gov.br**.",
                screens: [],
                suggestedActions: ["Ver Tabela de Integrações", "O que você pode fazer?", "Consultar MEI", "Consultar IPVA"],
                actionCard: nil
            )
        }
        
        // ---------------------------------------------------------
        // SERVIÇOS NATIVAMENTE SUPORTADOS
        // ---------------------------------------------------------
        
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
    
    // MARK: - Real-Time QR Code Invite Handshake (Two-Way Auto-Navigation)
    
    private var localAcceptedInvites: [String: String] = [:]
    private let remoteBaseURL = URL(string: "https://govi.chat")!
    
    private struct QRInviteStatusResponse: Codable {
        let id: String
        let status: String
        let acceptedBy: AcceptedByPayload?
        
        struct AcceptedByPayload: Codable {
            let name: String
            let mxid: String
            let level: String
            let roomId: String?
            let acceptedUrl: String?
        }
    }
    
    public func registerQRInvite(_ invite: EphemeralInvite) async {
        let body: [String: String] = [
            "id": invite.id,
            "senderId": invite.senderId,
            "senderDisplayName": invite.senderDisplayName,
            "senderAccountLevel": invite.senderAccountLevel.rawValue
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        for hostURL in [baseURL, remoteBaseURL] {
            var request = URLRequest(url: hostURL.appendingPathComponent("api/govi/invites"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = 3.0
            _ = try? await session.data(for: request)
        }
    }
    
    public func checkQRInviteStatus(inviteId: String) async -> String? {
        let cleanId = inviteId.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let localAccepted = localAcceptedInvites[cleanId] {
            localAcceptedInvites.removeValue(forKey: cleanId)
            return localAccepted
        }
        
        for hostURL in [baseURL, remoteBaseURL] {
            var request = URLRequest(url: hostURL.appendingPathComponent("api/govi/invites/\(cleanId)"))
            request.httpMethod = "GET"
            request.timeoutInterval = 2.5
            if let (data, response) = try? await session.data(for: request),
               let http = response as? HTTPURLResponse,
               (200...299).contains(http.statusCode),
               let decoded = try? JSONDecoder().decode(QRInviteStatusResponse.self, from: data),
               decoded.status == "accepted",
               let accepted = decoded.acceptedBy {
                if let urlStr = accepted.acceptedUrl, !urlStr.isEmpty {
                    return urlStr
                }
                let fallbackURL = "https://govi.chat/c/\(cleanId)?name=\(accepted.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? accepted.name)&mxid=\(accepted.mxid)&level=\(accepted.level)"
                return fallbackURL
            }
        }
        return nil
    }
    
    public func acceptQRInvite(scannedPayload: String, scannerProfile: UserProfile) async {
        let trimmed = scannedPayload.trimmingCharacters(in: .whitespacesAndNewlines)
        var inviteId: String = UUID().uuidString.prefix(8).lowercased()
        if let url = URL(string: trimmed) {
            let last = url.lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if !last.isEmpty && last != "/" && last != "c" {
                inviteId = last
            }
        }
        
        let scannerMxid = MatrixUserId.fromCpf(scannerProfile.cpf).rawValue
        let acceptedURL = "https://govi.chat/c/\(inviteId)?name=\(scannerProfile.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? scannerProfile.name)&mxid=\(scannerMxid)&level=\(scannerProfile.accountLevel.rawValue)"
        localAcceptedInvites[inviteId] = acceptedURL
        
        let body: [String: String] = [
            "scannerName": scannerProfile.name,
            "scannerMatrixId": scannerMxid,
            "scannerAccountLevel": scannerProfile.accountLevel.rawValue
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        for hostURL in [baseURL, remoteBaseURL] {
            var request = URLRequest(url: hostURL.appendingPathComponent("api/govi/invites/\(inviteId)/accept"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            request.timeoutInterval = 3.0
            _ = try? await session.data(for: request)
        }
    }
}
