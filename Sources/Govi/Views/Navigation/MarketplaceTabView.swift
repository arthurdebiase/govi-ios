import SwiftUI

public struct MarketplaceTabView: View {
    @Bindable public var viewModel: MarketplaceViewModel
    @State private var selectedDetailService: GovService? = nil
    
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
                        Button {
                            HapticManager.shared.selection()
                            selectedDetailService = service
                        } label: {
                            HStack(alignment: .center, spacing: 14) {
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
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    if service.isConnected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color(UIColor.systemGreen))
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                                }
                            }
                            .contentShape(Rectangle())
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
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
            .sheet(item: $selectedDetailService) { service in
                AppDetailSheet(
                    service: service,
                    isConnected: viewModel.services.first(where: { $0.id == service.id })?.isConnected ?? false,
                    onToggleConnection: {
                        viewModel.toggleConnection(for: service.id)
                    }
                )
            }
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
