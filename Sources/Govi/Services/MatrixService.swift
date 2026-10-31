import Foundation

public actor MatrixService {
    public static let shared = MatrixService()
    
    public private(set) var currentSession: MatrixSession?
    public private(set) var isConnected: Bool = false
    
    private let defaultHomeserver = URL(string: "https://matrix.gov.br")!
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8.0
        self.session = URLSession(configuration: config)
    }
    
    public func authenticateWithGovBr(
        cpf: String,
        accountLevel: GovBrAccountLevel,
        token: String = "govbr_oauth2_jwt_sample"
    ) -> MatrixSession {
        let userId = MatrixUserId.fromCpf(cpf).rawValue
        let deviceId = "IPHONE_SECURE_ENCLAVE_\(abs(cpf.hashValue % 9999))"
        let fingerprint = generateFingerprint(for: "\(userId):\(deviceId)")
        
        let newSession = MatrixSession(
            userId: userId,
            deviceId: deviceId,
            accessToken: "syt_\(UUID().uuidString.prefix(12))",
            homeserver: defaultHomeserver,
            e2eeStatus: MatrixE2EEStatus(
                isEncrypted: true,
                algorithm: .megolm,
                isCrossSigningVerified: accountLevel == .ouro || accountLevel == .prata,
                keyFingerprint: fingerprint
            )
        )
        self.currentSession = newSession
        self.isConnected = true
        return newSession
    }
    
    public func createRoom(
        title: String,
        isDirect: Bool = true,
        invitee: String
    ) -> String {
        let cleanId = title
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined(separator: "_")
        return "!room_\(cleanId)_\(UUID().uuidString.prefix(6)):gov.br"
    }
    
    public func sendMatrixEvent(
        roomId: String,
        body: String,
        actionCard: ActionCard? = nil
    ) async -> Message {
        let eventId = "$m_\(UUID().uuidString.prefix(12))"
        
        // In full Matrix production, sends PUT /_matrix/client/v3/rooms/{roomId}/send/m.room.message/{txnId}
        return Message(
            role: .user,
            content: body,
            actionCard: actionCard,
            matrixEventId: eventId,
            isEncrypted: true
        )
    }
    
    public func verifyPartnerCrossSigning(partnerId: String) -> Bool {
        // Partners on *.gov.br with official roles or authenticated CPF are verified
        return partnerId.contains("gov.br")
    }
    
    private func generateFingerprint(for seed: String) -> String {
        var hash = abs(seed.hashValue)
        var parts: [String] = []
        for _ in 0..<6 {
            let part = String(format: "%04X", hash % 0xFFFF)
            parts.append(part)
            hash = hash / 7
        }
        return parts.joined(separator: " ")
    }
}
