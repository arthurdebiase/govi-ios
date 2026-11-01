import Foundation
import SwiftUI

public struct GovAppOption: Identifiable, Hashable, Sendable {
    public let id: String
    public let slug: String
    public let name: String
    public let shortName: String
    public let category: String
    public let sphere: String
    public let thumbnailUrl: String?
    public let systemImage: String
    public let iconBgColor: String
    public let description: String
    public let skillsPromptSnippet: String
    public let rating: Double
    public let downloads: String
    public let popularRank: Int
    public let featured: Bool
    
    public init(
        id: String,
        slug: String = "",
        name: String,
        shortName: String,
        category: String,
        sphere: String = "Federal",
        thumbnailUrl: String? = nil,
        systemImage: String,
        iconBgColor: String,
        description: String,
        skillsPromptSnippet: String,
        rating: Double = 4.8,
        downloads: String = "+1M",
        popularRank: Int = 99,
        featured: Bool = false
    ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.shortName = shortName
        self.category = category
        self.sphere = sphere
        self.thumbnailUrl = thumbnailUrl
        self.systemImage = systemImage
        self.iconBgColor = iconBgColor
        self.description = description
        self.skillsPromptSnippet = skillsPromptSnippet
        self.rating = rating
        self.downloads = downloads
        self.popularRank = popularRank
        self.featured = featured
    }
}
