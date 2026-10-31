import SwiftUI

public struct GlobalSearchView: View {
    @Bindable public var marketplaceViewModel: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var recentSearches: [String] = [
        "Guia DAS-MEI", "Certidão CND", "IPVA 2026", "Extrato CNIS", "CRLV Digital"
    ]
    
    public init(marketplaceViewModel: MarketplaceViewModel) {
        self.marketplaceViewModel = marketplaceViewModel
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // If search query is empty -> show quick chips and categories
                if searchText.isEmpty {
                    Section("Buscas Recentes") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(recentSearches, id: \.self) { term in
                                    Button(action: {
                                        HapticManager.shared.impact(.light)
                                        searchText = term
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "magnifyingglass")
                                                .font(.caption2)
                                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                            Text(term)
                                                .font(.subheadline)
                                                .foregroundStyle(Color(UIColor.label))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(UIColor.separator), lineWidth: 0.6)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                    
                    Section("Categorias de Serviços") {
                        ForEach(marketplaceViewModel.categories.filter { $0 != "Todos" }, id: \.self) { cat in
                            Button(action: {
                                HapticManager.shared.impact(.light)
                                searchText = cat
                            }) {
                                HStack {
                                    Label(cat, systemImage: iconForCategory(cat))
                                        .foregroundStyle(Color(UIColor.label))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                                }
                            }
                        }
                    }
                } else {
                    // Search Results
                    let matchedServices = marketplaceViewModel.services.filter {
                        $0.name.localizedCaseInsensitiveContains(searchText) ||
                        $0.description.localizedCaseInsensitiveContains(searchText) ||
                        $0.category.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    if matchedServices.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .listRowBackground(Color.clear)
                    } else {
                        Section("Serviços Públicos (\(matchedServices.count))") {
                            ForEach(matchedServices) { service in
                                HStack(spacing: 12) {
                                    Image(systemName: service.systemImage)
                                        .font(.title3)
                                        .foregroundStyle(Color(UIColor.systemBlue))
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(service.name)
                                            .font(.headline)
                                        Text(service.category)
                                            .font(.caption)
                                            .foregroundStyle(Color(UIColor.secondaryLabel))
                                    }
                                    Spacer()
                                    if service.isConnected {
                                        Text("Conectado")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color(UIColor.systemGreen))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Buscar serviços e canais gov.br")
            .navigationTitle("Buscar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Geral & Identidade": return "person.badge.shield.checkmark"
        case "Previdência & Seguridade": return "heart.text.square.fill"
        case "Trânsito & Veículos": return "car.fill"
        case "Tributos & Fazenda": return "building.columns.fill"
        case "Negócios & MEI": return "briefcase.fill"
        case "Trabalho & Emprego": return "doc.text.image.fill"
        case "Cidadania & Voto": return "checkmark.seal.fill"
        case "Saúde Pública": return "cross.case.fill"
        default: return "circle.grid.2x2.fill"
        }
    }
}
