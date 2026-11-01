import Foundation

public struct GovService: Identifiable, Codable, Sendable, Equatable {
    public let id: Int
    public let slug: String
    public let name: String
    public let category: String
    public let sphere: String
    public let description: String
    public let systemImage: String
    public let thumbnailUrl: String?
    public var isConnected: Bool
    public let screenCount: Int
    public let officialUrl: String
    public let rating: Double
    public let downloads: String
    
    public init(
        id: Int,
        slug: String = "",
        name: String,
        category: String,
        sphere: String = "Federal",
        description: String,
        systemImage: String,
        thumbnailUrl: String? = nil,
        isConnected: Bool = true,
        screenCount: Int = 12,
        officialUrl: String = "https://www.gov.br",
        rating: Double = 4.8,
        downloads: String = "+1M"
    ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.category = category
        self.sphere = sphere
        self.description = description
        self.systemImage = systemImage
        self.thumbnailUrl = thumbnailUrl
        self.isConnected = isConnected
        self.screenCount = screenCount
        self.officialUrl = officialUrl
        self.rating = rating
        self.downloads = downloads
    }
}
