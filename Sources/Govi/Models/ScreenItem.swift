import Foundation

public struct ScreenItem: Identifiable, Codable, Sendable, Equatable {
    public let id: Int
    public let appId: Int?
    public let name: String
    public let flow: String?
    public let order: Int?
    public let tags: [String]?
    public let imageUrl: String?
    public let cloudinaryUrl: String?
    public let altText: String?
    
    public init(
        id: Int,
        appId: Int? = nil,
        name: String,
        flow: String? = nil,
        order: Int? = nil,
        tags: [String]? = nil,
        imageUrl: String? = nil,
        cloudinaryUrl: String? = nil,
        altText: String? = nil
    ) {
        self.id = id
        self.appId = appId
        self.name = name
        self.flow = flow
        self.order = order
        self.tags = tags
        self.imageUrl = imageUrl
        self.cloudinaryUrl = cloudinaryUrl
        self.altText = altText
    }
    
    public var displayUrl: String {
        cloudinaryUrl ?? imageUrl ?? ""
    }
}
