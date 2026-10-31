import Foundation

public struct GovService: Identifiable, Codable, Sendable, Equatable {
    public let id: Int
    public let name: String
    public let category: String
    public let description: String
    public let systemImage: String
    public var isConnected: Bool
    public let screenCount: Int
    public let officialUrl: String
    
    public init(
        id: Int,
        name: String,
        category: String,
        description: String,
        systemImage: String,
        isConnected: Bool = true,
        screenCount: Int = 12,
        officialUrl: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.systemImage = systemImage
        self.isConnected = isConnected
        self.screenCount = screenCount
        self.officialUrl = officialUrl
    }
    
    public static let defaultServices: [GovService] = [
        GovService(
            id: 1,
            name: "gov.br (Aplicativo Oficial)",
            category: "Geral & Identidade",
            description: "Identidade digital, assinatura avançada, prova de vida e níveis Bronze/Prata/Ouro.",
            systemImage: "person.badge.shield.checkmark",
            isConnected: true,
            screenCount: 24,
            officialUrl: "https://www.gov.br/pt-br/aplicativos/aplicativo-gov.br"
        ),
        GovService(
            id: 2,
            name: "Meu INSS",
            category: "Previdência & Seguridade",
            description: "Extrato CNIS, simulação de aposentadoria, salário-maternidade e perícia médica.",
            systemImage: "heart.text.square.fill",
            isConnected: true,
            screenCount: 42,
            officialUrl: "https://meu.inss.gov.br"
        ),
        GovService(
            id: 3,
            name: "Carteira Digital de Trânsito (CDT)",
            category: "Trânsito & Veículos",
            description: "CNH digital no celular, CRLV-e, pagamento de IPVA e consulta de infrações com 40% de desconto.",
            systemImage: "car.fill",
            isConnected: true,
            screenCount: 38,
            officialUrl: "https://portalservicos.senatran.serpro.gov.br"
        ),
        GovService(
            id: 4,
            name: "Receita Federal / e-CAC",
            category: "Tributos & Fazenda",
            description: "Declaração de IRPF, malha fina, certidões negativas de débitos federais (CND) e regularização de CPF.",
            systemImage: "building.columns.fill",
            isConnected: true,
            screenCount: 31,
            officialUrl: "https://cav.receita.fazenda.gov.br"
        ),
        GovService(
            id: 5,
            name: "MEI Fácil & Portal do Empreendedor",
            category: "Negócios & MEI",
            description: "Emissão de guia DAS-MEI mensal, declaração DASN-SIMEI, CCMEI e regularização de débitos.",
            systemImage: "briefcase.fill",
            isConnected: true,
            screenCount: 19,
            officialUrl: "https://www.gov.br/empresas-e-negocios/pt-br/empreendedor"
        ),
        GovService(
            id: 6,
            name: "Carteira de Trabalho Digital",
            category: "Trabalho & Emprego",
            description: "Histórico de vínculos da CLT, anotações de férias e salário, e requerimento do Seguro-Desemprego.",
            systemImage: "doc.text.image.fill",
            isConnected: true,
            screenCount: 22,
            officialUrl: "https://www.gov.br/trabalho-e-emprego/pt-br/servicos/trabalhador/carteira-de-trabalho-digital"
        ),
        GovService(
            id: 7,
            name: "e-Título",
            category: "Cidadania & Voto",
            description: "Título de eleitor digital com foto para votação, quitação eleitoral e justificativa de ausência.",
            systemImage: "checkmark.seal.fill",
            isConnected: false,
            screenCount: 14,
            officialUrl: "https://www.tse.jus.br/servicos-eleitorais/titulo-e-local-de-votacao/e-titulo"
        ),
        GovService(
            id: 8,
            name: "Conecte SUS Cidadão",
            category: "Saúde Pública",
            description: "Carteira nacional de vacinação, agendamento de consultas na UBS e histórico de medicamentos.",
            systemImage: "cross.case.fill",
            isConnected: false,
            screenCount: 16,
            officialUrl: "https://conectesus-paciente.saude.gov.br"
        )
    ]
}
