import Foundation

public enum ActionCardType: String, Codable, Sendable {
    case pixPayment = "PIX_PAYMENT"
    case documentReady = "DOCUMENT_READY"
    case vehicleReport = "VEHICLE_REPORT"
    case debtStatus = "DEBT_STATUS"
    case identityBadge = "IDENTITY_BADGE"
}

public enum ActionCardStatus: String, Codable, Sendable {
    case success
    case warning
    case pending
    case info
}

public struct ActionCardButton: Identifiable, Codable, Sendable, Equatable {
    public var id: String { action }
    public let label: String
    public let action: String
    public let variant: String?
    public let payloadText: String?
    
    public init(label: String, action: String, variant: String? = "primary", payloadText: String? = nil) {
        self.label = label
        self.action = action
        self.variant = variant
        self.payloadText = payloadText
    }
}

public struct ActionCard: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let type: ActionCardType
    public let title: String
    public let subtitle: String?
    public let status: ActionCardStatus
    public let data: [String: String]
    public let actions: [ActionCardButton]?
    
    public init(
        id: String,
        type: ActionCardType,
        title: String,
        subtitle: String? = nil,
        status: ActionCardStatus = .info,
        data: [String: String],
        actions: [ActionCardButton]? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.data = data
        self.actions = actions
    }
}
