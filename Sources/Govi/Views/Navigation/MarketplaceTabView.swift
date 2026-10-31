import SwiftUI

public struct MarketplaceTabView: View {
    @Bindable public var viewModel: MarketplaceViewModel
    
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
                
                // Tabela de Integrações para o Futuro (Roadmap solicitado pelo Cidadão)
                Section {
                    if IntegrationsStore.shared.futureIntegrations.isEmpty {
                        Text("Nenhuma integração pendente. Ao pedir uma ação no chat que o Govi ainda não realiza, ela será anotada aqui automaticamente!")
                            .font(.subheadline)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .padding(.vertical, 4)
                    } else {
                        ForEach(IntegrationsStore.shared.futureIntegrations) { integ in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(integ.title)
                                            .font(.headline)
                                            .foregroundStyle(Color(UIColor.label))
                                        
                                        Text("Órgão: \(integ.agency) • \(integ.category)")
                                            .font(.caption)
                                            .foregroundStyle(Color(UIColor.secondaryLabel))
                                    }
                                    
                                    Spacer()
                                    
                                    Text(integ.status)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(UIColor.systemGreen).opacity(0.15))
                                        .foregroundStyle(Color(UIColor.systemGreen))
                                        .clipShape(Capsule())
                                }
                                
                                Text("\"\(integ.userPrompt)\"")
                                    .font(.caption)
                                    .italic()
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                    .padding(.top, 2)
                                
                                HStack {
                                    Label(integ.formattedDate, systemImage: "clock")
                                        .font(.caption2)
                                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                                    
                                    Spacer()
                                    
                                    Label("Prioridade \(integ.priority)", systemImage: "chart.line.uptrend.xyaxis")
                                        .font(.caption2)
                                        .foregroundStyle(Color(UIColor.systemBlue))
                                }
                                .padding(.top, 2)
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    IntegrationsStore.shared.removeIntegration(integ)
                                } label: {
                                    Label("Remover", systemImage: "trash")
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Label("Tabela de Integrações para o Futuro", systemImage: "sparkles.rectangle.stack")
                        Spacer()
                        Text("\(IntegrationsStore.shared.futureIntegrations.count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(UIColor.systemBlue).opacity(0.15))
                            .foregroundStyle(Color(UIColor.systemBlue))
                            .clipShape(Capsule())
                    }
                } footer: {
                    Text("Quando você solicita uma ação no chat do Govi que ainda não possui integração direta com o órgão responsável, ela é registrada nesta tabela para priorização contínua do sistema.")
                        .font(.caption2)
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $viewModel.searchText, prompt: "Filtrar serviços públicos")
            .navigationTitle("Conectar")
        }
    }
}
