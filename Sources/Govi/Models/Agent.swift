import Foundation
import SwiftUI

public enum AgentAvatarType: String, Codable, Sendable, CaseIterable {
    case `default`
    case pension
    case transit
    case finance
    case citizen
    case custom
    
    public var systemImageName: String {
        switch self {
        case .default: return "sparkles"
        case .pension: return "heart.text.square"
        case .transit: return "car.fill"
        case .finance: return "brazilianrealsign.circle.fill"
        case .citizen: return "person.text.rectangle"
        case .custom: return "gearshape.2.fill"
        }
    }
}

public struct AgentColors: Codable, Sendable, Equatable {
    public var background: String
    public var semiCircle: String
    public var circle: String
    public var stripe: String
    
    public init(background: String, semiCircle: String, circle: String, stripe: String) {
        self.background = background
        self.semiCircle = semiCircle
        self.circle = circle
        self.stripe = stripe
    }
    
    public static let `default` = AgentColors(
        background: "#009440",
        semiCircle: "#FFCB00",
        circle: "#302681",
        stripe: "#FFFFFF"
    )
}

public struct AgentCapability: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let systemImage: String
    
    public init(id: String, name: String, description: String, systemImage: String = "checkmark.shield") {
        self.id = id
        self.name = name
        self.description = description
        self.systemImage = systemImage
    }
}

public struct GovBrAgent: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var name: String
    public var description: String
    public var avatarType: AgentAvatarType
    public var colors: AgentColors
    public var systemPrompt: String
    public var allowedCapabilities: [String]
    public var isDefault: Bool
    
    public init(
        id: String,
        name: String,
        description: String,
        avatarType: AgentAvatarType = .default,
        colors: AgentColors = .default,
        systemPrompt: String,
        allowedCapabilities: [String] = [],
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.avatarType = avatarType
        self.colors = colors
        self.systemPrompt = systemPrompt
        self.allowedCapabilities = allowedCapabilities
        self.isDefault = isDefault
    }
}

public extension GovBrAgent {
    static let availableCapabilities: [AgentCapability] = [
        AgentCapability(
            id: "consultar_telas",
            name: "Consultar acervo de telas e fluxos",
            description: "Permite à IA inspecionar os fluxos de UX e telas oficiais governamentais.",
            systemImage: "photo.stack"
        ),
        AgentCapability(
            id: "simular_fluxos",
            name: "Simular etapas no aplicativo",
            description: "Permite orquestrar passos sequenciais de autoatendimento como um agente autônomo.",
            systemImage: "arrow.triangle.turn.up.right.diamond"
        ),
        AgentCapability(
            id: "emitir_documentos",
            name: "Emissão de certidões e comprovantes (PDF)",
            description: "Permite orientar e gerar comprovantes, certidões negativas e guias públicas.",
            systemImage: "doc.badge.arrow.up"
        ),
        AgentCapability(
            id: "transacoes_financeiras",
            name: "Ações financeiras (Pix, boletos e taxas)",
            description: "Permite preparar guias DAS, Pix do IPVA e consultas de pendências tributárias.",
            systemImage: "brazilianrealsign.circle"
        ),
        AgentCapability(
            id: "dados_sigilosos",
            name: "Acesso a dados cadastrais e previdenciários",
            description: "Permite consultar extratos CNIS, tempo de contribuição e situação do CPF.",
            systemImage: "lock.shield"
        )
    ]
    
    static let defaultAgents: [GovBrAgent] = [
        GovBrAgent(
            id: "govbr-default",
            name: "Govi (Padrão)",
            description: "Copilot geral para serviços públicos, níveis de conta (Prata/Ouro) e navegação integrada.",
            avatarType: .default,
            colors: AgentColors(background: "#009440", semiCircle: "#FFCB00", circle: "#302681", stripe: "#FFFFFF"),
            systemPrompt: "Você é o Govi (agente padrão). Auxilie o cidadão em todos os serviços públicos digitais brasileiros com clareza, empatia e segurança.",
            allowedCapabilities: ["consultar_telas", "simular_fluxos", "emitir_documentos", "transacoes_financeiras", "dados_sigilosos"],
            isDefault: true
        ),
        GovBrAgent(
            id: "agent-mei-fiscal",
            name: "MEI & Tributos",
            description: "Especialista em Guia DAS do MEI, Declaração Anual (DASN-SIMEI), Simples Nacional e CND da Receita.",
            avatarType: .finance,
            colors: AgentColors(background: "#059669", semiCircle: "#34D399", circle: "#FBBF24", stripe: "#064E3B"),
            systemPrompt: "Você é o especialista em MEI e finanças públicas. Priorize geração de guias DAS mensais e certidões.",
            allowedCapabilities: ["emitir_documentos", "transacoes_financeiras", "consultar_telas"],
            isDefault: false
        ),
        GovBrAgent(
            id: "agent-previdencia",
            name: "Previdência & Benefícios",
            description: "Especialista em Meu INSS, extrato CNIS, FGTS, aposentadorias e perícia médica.",
            avatarType: .pension,
            colors: AgentColors(background: "#6D28D9", semiCircle: "#A78BFA", circle: "#F59E0B", stripe: "#2E1065"),
            systemPrompt: "Você é um agente especialista em previdência social e benefícios federais (Meu INSS, FGTS e Caixa).",
            allowedCapabilities: ["consultar_telas", "simular_fluxos", "emitir_documentos", "dados_sigilosos"],
            isDefault: false
        ),
        GovBrAgent(
            id: "agent-transito",
            name: "Trânsito & Veículos",
            description: "Focado em Carteira Digital de Trânsito (CDT), CRLV-e, pontuação de CNH, IPVA e multas.",
            avatarType: .transit,
            colors: AgentColors(background: "#0284C7", semiCircle: "#38BDF8", circle: "#0F172A", stripe: "#F8FAFC"),
            systemPrompt: "Você é um especialista em serviços de trânsito e condutores. Guie o usuário na navegação da CDT.",
            allowedCapabilities: ["consultar_telas", "simular_fluxos", "transacoes_financeiras"],
            isDefault: false
        ),
        GovBrAgent(
            id: "agent-trabalho-cidadao",
            name: "Trabalho & Documentos",
            description: "Carteira de Trabalho Digital, seguro-desemprego, PIS/PASEP e certidão trabalhista (CNDT).",
            avatarType: .citizen,
            colors: AgentColors(background: "#EA580C", semiCircle: "#FB923C", circle: "#1E3A8A", stripe: "#FFF7ED"),
            systemPrompt: "Você é o especialista em direitos trabalhistas e documentação cívica.",
            allowedCapabilities: ["consultar_telas", "emitir_documentos", "dados_sigilosos"],
            isDefault: false
        )
    ]
}
