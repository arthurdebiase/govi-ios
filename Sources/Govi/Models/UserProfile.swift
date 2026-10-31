import Foundation

public enum GovBrAccountLevel: String, Codable, Sendable {
    case bronze = "Bronze"
    case prata = "Prata"
    case ouro = "Ouro"
}

public struct UserVehicle: Identifiable, Codable, Sendable, Equatable {
    public var id: String { placa }
    public let placa: String
    public let modelo: String
    public let renavam: String
    public let ano: String
    public let situacao: String
    
    public init(placa: String, modelo: String, renavam: String, ano: String, situacao: String = "Regular") {
        self.placa = placa
        self.modelo = modelo
        self.renavam = renavam
        self.ano = ano
        self.situacao = situacao
    }
}

public struct UserProfile: Codable, Sendable, Equatable {
    public var name: String
    public var cpf: String
    public var email: String
    public var accountLevel: GovBrAccountLevel
    public var isMock: Bool
    public var cnpj: String?
    public var cnhCategoria: String?
    public var cnhPontos: Int
    public var vehicles: [UserVehicle]
    
    public init(
        name: String = "Arthur Debiase",
        cpf: String = "123.842.198-00",
        email: String = "arthur.debiase@gov.br",
        accountLevel: GovBrAccountLevel = .ouro,
        isMock: Bool = true,
        cnpj: String? = "48.291.834/0001-92",
        cnhCategoria: String? = "AB",
        cnhPontos: Int = 0,
        vehicles: [UserVehicle] = [
            UserVehicle(placa: "BRA2E19", modelo: "HYUNDAI HB20 1.0M COMFORT", renavam: "00987654321", ano: "2023/2024")
        ]
    ) {
        self.name = name
        self.cpf = cpf
        self.email = email
        self.accountLevel = accountLevel
        self.isMock = isMock
        self.cnpj = cnpj
        self.cnhCategoria = cnhCategoria
        self.cnhPontos = cnhPontos
        self.vehicles = vehicles
    }
    
    public var maskedCpf: String {
        let clean = cpf.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")
        guard clean.count == 11 else { return cpf }
        let start = clean.prefix(3)
        let end = clean.suffix(2)
        return "\(start).***.***-\(end)"
    }
}
