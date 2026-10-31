import Foundation

public enum MessageRole: String, Codable, Sendable {
    case user
    case assistant
}

public struct Message: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let role: MessageRole
    public var content: String
    public var screens: [ScreenItem]?
    public var suggestedActions: [String]?
    public var actionCard: ActionCard?
    public let timestamp: String
    public let date: Date
    
    public init(
        id: String = UUID().uuidString,
        role: MessageRole,
        content: String,
        screens: [ScreenItem]? = nil,
        suggestedActions: [String]? = nil,
        actionCard: ActionCard? = nil,
        timestamp: String? = nil,
        date: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.screens = screens
        self.suggestedActions = suggestedActions
        self.actionCard = actionCard
        self.date = date
        
        if let timestamp = timestamp {
            self.timestamp = timestamp
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self.timestamp = formatter.string(from: date)
        }
    }
}
