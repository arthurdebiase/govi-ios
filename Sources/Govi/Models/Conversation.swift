import Foundation

public enum ConversationPartnerType: String, Codable, Sendable, CaseIterable {
    case all = "Todos"
    case agent = "Agentes Virtuais"
    case person = "Atendentes Oficiais"
}

public struct Conversation: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public var agentId: String?
    public var type: String // "agent" | "person"
    public var title: String
    
    // Person fields
    public var personName: String?
    public var personRole: String?
    public var personAvatarUrl: String?
    public var personInitials: String?
    public var personOnline: Bool?
    
    // Agent fields
    public var agentName: String?
    public var agentColors: AgentColors?
    
    public var isPinned: Bool
    public var isMuted: Bool
    public var unreadCount: Int
    
    public var messages: [Message]
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        agentId: String? = nil,
        type: String = "agent",
        title: String,
        personName: String? = nil,
        personRole: String? = nil,
        personAvatarUrl: String? = nil,
        personInitials: String? = nil,
        personOnline: Bool? = nil,
        agentName: String? = nil,
        agentColors: AgentColors? = nil,
        isPinned: Bool = false,
        isMuted: Bool = false,
        unreadCount: Int = 0,
        messages: [Message] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.agentId = agentId
        self.type = type
        self.title = title
        self.personName = personName
        self.personRole = personRole
        self.personAvatarUrl = personAvatarUrl
        self.personInitials = personInitials
        self.personOnline = personOnline
        self.agentName = agentName
        self.agentColors = agentColors
        self.isPinned = isPinned
        self.isMuted = isMuted
        self.unreadCount = unreadCount
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public var displayName: String {
        if type == "person" {
            return personName ?? "Atendente Oficial"
        }
        return agentName ?? title
    }
    
    public var displaySubtitle: String {
        if type == "person" {
            return personRole ?? "Serviço Público Federal"
        }
        return title
    }
    
    public var lastMessageText: String {
        if let last = messages.last {
            return last.content
        }
        return "Nova conversa iniciada"
    }
    
    public var lastMessageTime: String {
        if let last = messages.last {
            return last.timestamp
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: updatedAt)
    }
}
