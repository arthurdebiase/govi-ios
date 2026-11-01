import Foundation
import SwiftUI

public struct GovAppOption: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let shortName: String
    public let category: String
    public let systemImage: String
    public let iconBgColor: String
    public let description: String
    public let skillsPromptSnippet: String
    
    public init(
        id: String,
        name: String,
        shortName: String,
        category: String,
        systemImage: String,
        iconBgColor: String,
        description: String,
        skillsPromptSnippet: String
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.category = category
        self.systemImage = systemImage
        self.iconBgColor = iconBgColor
        self.description = description
        self.skillsPromptSnippet = skillsPromptSnippet
    }
    
    public static let defaultApps: [GovAppOption] = [
        GovAppOption(
            id: "inss",
            name: "Meu INSS",
            shortName: "INSS",
            category: "Previdência",
            systemImage: "heart.text.square.fill",
            iconBgColor: "#0284C7",
            description: "Extrato CNIS, regras de transição, aposentadorias e perícias.",
            skillsPromptSnippet: "• Meu INSS: Especialista em simulação de aposentadoria por pontos e idade, extrato de vínculos do CNIS, agendamento de perícia e cálculo de benefícios previdenciários."
        ),
        GovAppOption(
            id: "receita",
            name: "Receita Federal",
            shortName: "Receita",
            category: "Tributos",
            systemImage: "building.columns.fill",
            iconBgColor: "#059669",
            description: "Certidão Negativa CND, IRPF, Malha Fina e Regularização de CPF.",
            skillsPromptSnippet: "• Receita Federal: Habilidade para emitir Certidão Negativa de Débitos (CND), orientar pendências de malha fina do IRPF e regularização cadastral do CPF."
        ),
        GovAppOption(
            id: "mei",
            name: "DAS & MEI",
            shortName: "PGMEI",
            category: "Empresas",
            systemImage: "banknote.fill",
            iconBgColor: "#10B981",
            description: "Emissão de DAS com Pix, Declaração Anual (DASN) e limites MEI.",
            skillsPromptSnippet: "• DAS & MEI: Emissão instantânea de guia mensal do DAS-MEI com Pix Copia e Cola, conferência de faturamento anual e baixa de pendências fiscais."
        ),
        GovAppOption(
            id: "cdt",
            name: "CDT Trânsito",
            shortName: "Trânsito",
            category: "Veículos",
            systemImage: "car.fill",
            iconBgColor: "#2563EB",
            description: "IPVA com desconto Pix, CRLV-e digital, multas e pontos CNH.",
            skillsPromptSnippet: "• CDT Trânsito: Consulta de débitos de veículos, cálculo do IPVA com desconto em cota única, geração de código Pix e emissão do CRLV digital."
        ),
        GovAppOption(
            id: "trabalho",
            name: "Trabalho Digital",
            shortName: "CTPS",
            category: "Trabalho",
            systemImage: "person.text.rectangle.fill",
            iconBgColor: "#7C3AED",
            description: "Carteira de Trabalho, seguro-desemprego, PIS/PASEP e abono.",
            skillsPromptSnippet: "• Carteira de Trabalho Digital: Consulta de contratos vigentes, histórico salarial, habilitação de seguro-desemprego e calendário do PIS/PASEP."
        ),
        GovAppOption(
            id: "conectesus",
            name: "Conecte SUS",
            shortName: "SUS",
            category: "Saúde",
            systemImage: "cross.case.fill",
            iconBgColor: "#0D9488",
            description: "Cartão SUS digital, vacinas, histórico de atendimentos e exames.",
            skillsPromptSnippet: "• Conecte SUS: Carteira de vacinação digital, número do Cartão Nacional de Saúde e orientações para agendamento de consultas na rede pública."
        ),
        GovAppOption(
            id: "fgts",
            name: "FGTS Caixa",
            shortName: "FGTS",
            category: "Benefícios",
            systemImage: "dollarsign.circle.fill",
            iconBgColor: "#F59E0B",
            description: "Saldo FGTS, saque-aniversário, rescisão e financiamento Caixa.",
            skillsPromptSnippet: "• FGTS & Caixa: Verificação de depósitos mensais das contas ativas e inativas, opção pelo Saque-Aniversário e cálculo rescisório."
        ),
        GovAppOption(
            id: "etitulo",
            name: "e-Título",
            shortName: "TSE",
            category: "Cidadania",
            systemImage: "person.badge.shield.checkmark.fill",
            iconBgColor: "#4F46E5",
            description: "Título de Eleitor, local de votação, quitação eleitoral e biometria.",
            skillsPromptSnippet: "• e-Título & TSE: Situação eleitoral, emissão de certidão de quitação e acompanhamento de transferência de domicílio pelo Título Net."
        ),
        GovAppOption(
            id: "pf",
            name: "Polícia Federal",
            shortName: "PF",
            category: "Documentos",
            systemImage: "shield.fill",
            iconBgColor: "#DC2626",
            description: "Emissão de passaporte, taxa GRU e antecedentes criminais.",
            skillsPromptSnippet: "• Polícia Federal: Orientações e checklist de documentos para emissão de passaporte, pagamento da taxa GRU e agendamento no posto oficial."
        ),
        GovAppOption(
            id: "govbr",
            name: "Gov.br Central",
            shortName: "Gov.br",
            category: "Identidade",
            systemImage: "star.fill",
            iconBgColor: "#302681",
            description: "Conta Prata/Ouro, assinatura digital e verificação em duas etapas.",
            skillsPromptSnippet: "• Gov.br Central: Validação facial para selos Prata e Ouro, assinatura digital de contratos e ativação de verificação em duas etapas (2FA)."
        ),
        GovAppOption(
            id: "poupatempo",
            name: "Poupatempo",
            shortName: "Poupatempo",
            category: "Serviços",
            systemImage: "clock.badge.checkmark.fill",
            iconBgColor: "#EA580C",
            description: "Agendamentos presenciais, 2ª via de RG/CIN e certidões estaduais.",
            skillsPromptSnippet: "• Poupatempo / Detran: Agendamento presencial para emissão da Carteira de Identidade Nacional (CIN) e renovação simplificada de CNH."
        ),
        GovAppOption(
            id: "bancos",
            name: "Open Finance",
            shortName: "Bancos",
            category: "Financeiro",
            systemImage: "arrow.left.arrow.right.circle.fill",
            iconBgColor: "#0891B2",
            description: "Integração bancária para pagamentos automáticos de tributos.",
            skillsPromptSnippet: "• Open Finance: Orientações de compartilhamento seguro de dados bancários e liquidação automatizada de guias governamentais via Pix."
        )
    ]
}
