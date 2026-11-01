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
                    Text("Conecte os 110+ aplicativos públicos oficiais do Brasil para que os agentes do Govi possam orientar suas etapas, consultar telas oficiais e emitir guias automaticamente.")
                        .font(.subheadline)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                    
                    Picker("Esfera", selection: $viewModel.selectedSphere) {
                        ForEach(viewModel.spheres, id: \.self) { sphere in
                            Text(sphere).tag(sphere)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }
                
                Section {
                    ForEach(viewModel.filteredServices) { service in
                        HStack(alignment: .top, spacing: 14) {
                            AppIconView(
                                urlString: service.thumbnailUrl,
                                systemImage: service.systemImage,
                                fallbackBgColor: "#0284C7",
                                appName: service.name,
                                size: 48
                            )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(service.name)
                                        .font(.headline)
                                        .foregroundStyle(Color(UIColor.label))
                                        .lineLimit(1)
                                    
                                    Text(service.sphere)
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(sphereBadgeColor(for: service.sphere).opacity(0.14))
                                        .foregroundStyle(sphereBadgeColor(for: service.sphere))
                                        .clipShape(Capsule())
                                }
                                
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
                                    
                                    Label(service.downloads, systemImage: "arrow.down.circle")
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
                } header: {
                    HStack {
                        Text("Serviços Disponíveis")
                        Spacer()
                        Text("\(viewModel.filteredServices.count) apps")
                            .font(.caption2)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
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
            .searchable(text: $viewModel.searchText, prompt: "Buscar em 110+ apps e serviços...")
            .navigationTitle("Conectar")
        }
    }
    
    private func sphereBadgeColor(for sphere: String) -> Color {
        switch sphere {
        case "Federal": return Color(UIColor.systemBlue)
        case "Estadual": return Color(UIColor.systemGreen)
        case "Municipal": return Color(UIColor.systemOrange)
        default: return Color(UIColor.systemGray)
        }
    }
}
