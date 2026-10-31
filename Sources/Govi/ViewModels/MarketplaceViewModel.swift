import Foundation
import SwiftUI

@MainActor
@Observable
public final class MarketplaceViewModel {
    public var services: [GovService] = GovService.defaultServices
    public var searchText: String = ""
    public var selectedCategory: String = "Todos"
    
    public init() {}
    
    public var categories: [String] {
        var set = Set(services.map { $0.category })
        var list = ["Todos"]
        list.append(contentsOf: set.sorted())
        return list
    }
    
    public var filteredServices: [GovService] {
        services.filter { service in
            let matchesCategory = selectedCategory == "Todos" || service.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                service.name.localizedCaseInsensitiveContains(searchText) ||
                service.description.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    public func toggleConnection(for serviceId: Int) {
        if let index = services.firstIndex(where: { $0.id == serviceId }) {
            services[index].isConnected.toggle()
            HapticManager.shared.impact(.light)
        }
    }
}
