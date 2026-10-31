import Foundation

public struct CivicContact: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let role: String
    public let initials: String
    public let matrixId: String
    public let accountLevel: GovBrAccountLevel
    public let isOnline: Bool
    public let department: String
    
    public init(
        id: String,
        name: String,
        role: String,
        initials: String,
        matrixId: String,
        accountLevel: GovBrAccountLevel = .ouro,
        isOnline: Bool = true,
        department: String
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.initials = initials
        self.matrixId = matrixId
        self.accountLevel = accountLevel
        self.isOnline = isOnline
        self.department = department
    }
    
    public static let defaultContacts: [CivicContact] = [
        CivicContact(
            id: "contact-camila",
            name: "Dra. Camila Mendes",
            role: "Auditora-Fiscal",
            initials: "CM",
            matrixId: "@camila.mendes:receita.gov.br",
            accountLevel: .ouro,
            isOnline: true,
            department: "Receita Federal"
        ),
        CivicContact(
            id: "contact-marcos",
            name: "Marcos Oliveira",
            role: "Analista de Benefícios",
            initials: "MO",
            matrixId: "@marcos.oliveira:inss.gov.br",
            accountLevel: .ouro,
            isOnline: true,
            department: "INSS"
        ),
        CivicContact(
            id: "contact-beatriz",
            name: "Dra. Beatriz Mendes",
            role: "Perita Médica Federal",
            initials: "BM",
            matrixId: "@beatriz.mendes:inss.gov.br",
            accountLevel: .ouro,
            isOnline: false,
            department: "Ministério da Previdência"
        ),
        CivicContact(
            id: "contact-lucas",
            name: "Lucas Vasconcelos",
            role: "Contador Credenciado • CRC-SP",
            initials: "LV",
            matrixId: "@lucas.contabilidade:crc.gov.br",
            accountLevel: .ouro,
            isOnline: true,
            department: "Conselho Regional de Contabilidade"
        ),
        CivicContact(
            id: "contact-juliana",
            name: "Juliana Rocha",
            role: "Agente de Atendimento",
            initials: "JR",
            matrixId: "@juliana.rocha:detran.sp.gov.br",
            accountLevel: .prata,
            isOnline: true,
            department: "Detran/SP"
        )
    ]
}
