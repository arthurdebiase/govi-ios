import Foundation

public struct MatrixUserId: Codable, Sendable, Equatable, Hashable {
    public let localpart: String
    public let domain: String
    
    public init(localpart: String, domain: String) {
        self.localpart = localpart
        self.domain = domain
    }
    
    public init?(string: String) {
        guard string.hasPrefix("@"), let colonIndex = string.firstIndex(of: ":") else {
            return nil
        }
        let local = String(string[string.index(after: string.startIndex)..<colonIndex])
        let dom = String(string[string.index(after: colonIndex)...])
        self.localpart = local
        self.domain = dom
    }
    
    public var rawValue: String {
        "@\(localpart):\(domain)"
    }
    
    public static func fromCpf(_ cpf: String, domain: String = "cidadao.gov.br") -> MatrixUserId {
        let clean = cpf.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return MatrixUserId(localpart: clean, domain: domain)
    }
    
    public static func fromAgentId(_ agentId: String, domain: String = "ia.gov.br") -> MatrixUserId {
        return MatrixUserId(localpart: agentId, domain: domain)
    }
    
    public static func fromPersonName(_ name: String, domain: String = "servidor.gov.br") -> MatrixUserId {
        let formatted = name
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .replacingOccurrences(of: "dra. ", with: "")
            .replacingOccurrences(of: "dr. ", with: "")
            .replacingOccurrences(of: " ", with: ".")
        return MatrixUserId(localpart: formatted, domain: domain)
    }
}

public enum MatrixEncryptionAlgorithm: String, Codable, Sendable {
    case megolm = "m.megolm.v1.aes-sha256"
    case olm = "m.olm.v1.curve25519-aes-sha256"
    case mls = "org.matrix.msc3814.mls"
}

public struct MatrixE2EEStatus: Codable, Sendable, Equatable {
    public let isEncrypted: Bool
    public let algorithm: MatrixEncryptionAlgorithm
    public let isCrossSigningVerified: Bool
    public let keyFingerprint: String
    
    public init(
        isEncrypted: Bool = true,
        algorithm: MatrixEncryptionAlgorithm = .megolm,
        isCrossSigningVerified: Bool = true,
        keyFingerprint: String = "7A9F 83E1 2C0B 94FD 551A E082"
    ) {
        self.isEncrypted = isEncrypted
        self.algorithm = algorithm
        self.isCrossSigningVerified = isCrossSigningVerified
        self.keyFingerprint = keyFingerprint
    }
}

public struct MatrixSession: Codable, Sendable, Equatable {
    public let userId: String
    public let deviceId: String
    public let accessToken: String
    public let homeserver: URL
    public let e2eeStatus: MatrixE2EEStatus
    
    public init(
        userId: String,
        deviceId: String = "IPHONE_SECURE_ENCLAVE_1",
        accessToken: String = "syt_govbr_sovereign_token_mock",
        homeserver: URL = URL(string: "https://matrix.gov.br")!,
        e2eeStatus: MatrixE2EEStatus = MatrixE2EEStatus()
    ) {
        self.userId = userId
        self.deviceId = deviceId
        self.accessToken = accessToken
        self.homeserver = homeserver
        self.e2eeStatus = e2eeStatus
    }
}
