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
    
    // Matrix Sovereign Protocol Fields
    public var matrixRoomId: String
    public var matrixPartnerId: String
    public var isE2EEEncrypted: Bool
    public var isCrossSigningVerified: Bool
    public var homeserverDomain: String
    public var keyFingerprint: String
    
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
        matrixRoomId: String? = nil,
        matrixPartnerId: String? = nil,
        isE2EEEncrypted: Bool = true,
        isCrossSigningVerified: Bool = true,
        homeserverDomain: String = "gov.br",
        keyFingerprint: String = "7A9F 83E1 2C0B 94FD 551A E082",
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
        
        // Matrix Sovereign IDs
        self.matrixRoomId = matrixRoomId ?? "!room_\(id):\(homeserverDomain)"
        if let partner = matrixPartnerId {
            self.matrixPartnerId = partner
        } else if type == "person", let name = personName {
            self.matrixPartnerId = MatrixUserId.fromPersonName(name, domain: homeserverDomain).rawValue
        } else if let aId = agentId {
            self.matrixPartnerId = MatrixUserId.fromAgentId(aId, domain: homeserverDomain).rawValue
        } else {
            self.matrixPartnerId = "@govi:ia.gov.br"
        }
        self.isE2EEEncrypted = isE2EEEncrypted
        self.isCrossSigningVerified = isCrossSigningVerified
        self.homeserverDomain = homeserverDomain
        self.keyFingerprint = keyFingerprint
        
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
