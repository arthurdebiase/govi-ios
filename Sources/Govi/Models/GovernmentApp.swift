import Foundation

public struct GovernmentApp: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let slug: String
    public let name: String
    public let description: String
    public let thumbnailUrl: String?
    public let category: String
    public let type: String?
    public let sphere: String?
    public let state: String?
    public let city: String?
    public let organization: String?
    public let platform: String?
    public let rating: Double?
    public let downloads: String?
    public let featured: Bool?
    public let featuredTagline: String?
    public let popularRank: Int?
    public let screenCount: Int?
    
    public init(
        id: Int,
        slug: String,
        name: String,
        description: String,
        thumbnailUrl: String?,
        category: String,
        type: String? = nil,
        sphere: String? = nil,
        state: String? = nil,
        city: String? = nil,
        organization: String? = nil,
        platform: String? = nil,
        rating: Double? = nil,
        downloads: String? = nil,
        featured: Bool? = nil,
        featuredTagline: String? = nil,
        popularRank: Int? = nil,
        screenCount: Int? = nil
    ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.description = description
        self.thumbnailUrl = thumbnailUrl
        self.category = category
        self.type = type
        self.sphere = sphere
        self.state = state
        self.city = city
        self.organization = organization
        self.platform = platform
        self.rating = rating
        self.downloads = downloads
        self.featured = featured
        self.featuredTagline = featuredTagline
        self.popularRank = popularRank
        self.screenCount = screenCount
    }
}
