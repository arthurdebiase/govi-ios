import Foundation

public struct EphemeralInvite: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let senderId: String
    public let senderDisplayName: String
    public let senderAccountLevel: GovBrAccountLevel
    public let createdAt: Date
    public let durationSeconds: Int
    public let isSingleUse: Bool
    
    public init(
        id: String = UUID().uuidString.prefix(8).lowercased(),
        senderId: String,
        senderDisplayName: String,
        senderAccountLevel: GovBrAccountLevel = .ouro,
        createdAt: Date = Date(),
        durationSeconds: Int = 60,
        isSingleUse: Bool = true
    ) {
        self.id = id
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.senderAccountLevel = senderAccountLevel
        self.createdAt = createdAt
        self.durationSeconds = durationSeconds
        self.isSingleUse = isSingleUse
    }
    
    public var expirationDate: Date {
        createdAt.addingTimeInterval(TimeInterval(durationSeconds))
    }
    
    public var isExpired: Bool {
        Date() > expirationDate
    }
    
    public var inviteURL: URL {
        URL(string: "https://govi.chat/c/\(id)")!
    }
}

public struct SelectiveDisclosurePermissions: Codable, Sendable, Equatable {
    public var shareFullName: Bool
    public var shareGovBrVerificationBadge: Bool
    public var shareMaskedCpf: Bool
    public var shareVehiclePlate: Bool
    public var shareCnpjMei: Bool
    
    public init(
        shareFullName: Bool = false,
        shareGovBrVerificationBadge: Bool = true,
        shareMaskedCpf: Bool = false,
        shareVehiclePlate: Bool = false,
        shareCnpjMei: Bool = false
    ) {
        self.shareFullName = shareFullName
        self.shareGovBrVerificationBadge = shareGovBrVerificationBadge
        self.shareMaskedCpf = shareMaskedCpf
        self.shareVehiclePlate = shareVehiclePlate
        self.shareCnpjMei = shareCnpjMei
    }
}

public struct ConversationRequest: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let senderDisplayName: String
    public let senderAccountLevel: GovBrAccountLevel
    public let senderInitials: String
    public let senderMatrixId: String
    public let timestamp: String
    public let introMessage: String
    
    public init(
        id: String = UUID().uuidString,
        senderDisplayName: String,
        senderAccountLevel: GovBrAccountLevel = .ouro,
        senderInitials: String,
        senderMatrixId: String,
        timestamp: String = "Agora há pouco",
        introMessage: String = "Gostaria de iniciar um atendimento seguro com você pelo Govi."
    ) {
        self.id = id
        self.senderDisplayName = senderDisplayName
        self.senderAccountLevel = senderAccountLevel
        self.senderInitials = senderInitials
        self.senderMatrixId = senderMatrixId
        self.timestamp = timestamp
        self.introMessage = introMessage
    }
}
