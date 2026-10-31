import Foundation

public struct FutureIntegration: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var title: String
    public var agency: String
    public var category: String
    public var status: String
    public var requestedAt: Date
    public var userPrompt: String
    public var priority: String
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        agency: String,
        category: String,
        status: String = "Anotado pelo Govi IA",
        requestedAt: Date = Date(),
        userPrompt: String,
        priority: String = "Normal"
    ) {
        self.id = id
        self.title = title
        self.agency = agency
        self.category = category
        self.status = status
        self.requestedAt = requestedAt
        self.userPrompt = userPrompt
        self.priority = priority
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: requestedAt)
    }
}
