import SwiftUI

public struct MarketplaceSheet: View {
    @Bindable public var viewModel: MarketplaceViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: MarketplaceViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Conecte os aplicativos públicos do gov.br para que os agentes do Govi possam orientar suas etapas, consultar telas oficiais e emitir guias automaticamente.")
                        .font(.subheadline)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                
                Section("Serviços Disponíveis") {
                    ForEach(viewModel.filteredServices) { service in
                        HStack(alignment: .top, spacing: 14) {
                            Circle()
                                .fill(Color(UIColor.secondarySystemFill))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: service.systemImage)
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color(UIColor.systemBlue))
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(service.name)
                                    .font(.headline)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Text(service.category)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                
                                Text(service.description)
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                    .lineLimit(2)
                                
                                HStack(spacing: 8) {
                                    Label("\(service.screenCount) telas mapeadas", systemImage: "photo.stack")
                                        .font(.caption2)
                                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                                }
                                .padding(.top, 2)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { service.isConnected },
                                set: { _ in viewModel.toggleConnection(for: service.id) }
                            ))
                            .labelsHidden()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $viewModel.searchText, prompt: "Buscar serviços e órgãos públicos")
            .navigationTitle("Conexões gov.br")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Concluído") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
