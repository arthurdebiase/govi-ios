import Foundation
import SwiftUI

@MainActor
@Observable
public final class MarketplaceViewModel {
    public var searchText: String = ""
    public var selectedSphere: String = "Todas"
    public var selectedCategory: String = "Todas"
    
    public init() {}
    
    public var services: [GovService] {
        GovernmentAppsStore.shared.govServices
    }
    
    public var spheres: [String] {
        ["Todas", "Federal", "Estadual", "Municipal"]
    }
    
    public var categories: [String] {
        let set = Set(services.map { $0.category })
        var list = ["Todas"]
        list.append(contentsOf: set.sorted())
        return list
    }
    
    public var filteredServices: [GovService] {
        services.filter { service in
            let matchesSphere = selectedSphere == "Todas" || service.sphere == selectedSphere
            let matchesCategory = selectedCategory == "Todas" || service.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                service.name.localizedCaseInsensitiveContains(searchText) ||
                service.description.localizedCaseInsensitiveContains(searchText)
            return matchesSphere && matchesCategory && matchesSearch
        }
    }
    
    public func toggleConnection(for serviceId: Int) {
        GovernmentAppsStore.shared.toggleConnection(for: serviceId)
    }
}
