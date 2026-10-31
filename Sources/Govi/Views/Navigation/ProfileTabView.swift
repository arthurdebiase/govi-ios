import SwiftUI

public struct ProfileTabView: View {
    @Bindable public var viewModel: ProfileViewModel
    
    public init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Citizen Header Section
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color(UIColor.secondarySystemFill))
                            .frame(width: 64, height: 64)
                            .overlay(
                                Text("AD")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(UIColor.label))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.profile.name)
                                .font(.headline)
                                .foregroundStyle(Color(UIColor.label))
                            
                            Text("CPF: \(viewModel.profile.maskedCpf)")
                                .font(.subheadline)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                            
                            HStack(spacing: 6) {
                                Label("Nível \(viewModel.profile.accountLevel.rawValue)", systemImage: "shield.lefthalf.filled.badge.checkmark")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(badgeColor)
                                
                                if viewModel.profile.isMock {
                                    Text("Simulação")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(UIColor.secondarySystemFill))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Nível da Conta gov.br
                Section("Nível de Confiabilidade gov.br") {
                    Picker("Nível da Conta", selection: Binding(
                        get: { viewModel.profile.accountLevel },
                        set: { viewModel.setAccountLevel($0) }
                    )) {
                        Text("Bronze").tag(GovBrAccountLevel.bronze)
                        Text("Prata").tag(GovBrAccountLevel.prata)
                        Text("Ouro (Recomendado)").tag(GovBrAccountLevel.ouro)
                    }
                    .pickerStyle(.segmented)
                    
                    Text("O nível Ouro concede acesso irrestrito a todos os serviços públicos, certidões com assinatura eletrônica e declaração pré-preenchida do IRPF.")
                        .font(.caption)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                
                // Carteira de Dados Cívicos
                Section("Carteira de Dados Integrada") {
                    if let cnpj = viewModel.profile.cnpj {
                        HStack {
                            Label("CNPJ MEI", systemImage: "briefcase.fill")
                            Spacer()
                            Text(cnpj)
                                .font(.caption)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                    }
                    
                    HStack {
                        Label("CNH Categoria", systemImage: "car.fill")
                        Spacer()
                        Text("\(viewModel.profile.cnhCategoria ?? "AB") • \(viewModel.profile.cnhPontos) pontos")
                            .font(.caption)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                    
                    ForEach(viewModel.profile.vehicles) { vehicle in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(vehicle.modelo)
                                    .font(.subheadline)
                                Text("Placa \(vehicle.placa) • Renavam \(vehicle.renavam)")
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                            }
                            Spacer()
                            Text(vehicle.situacao)
                                .font(.caption)
                                .foregroundStyle(Color(UIColor.systemGreen))
                        }
                    }
                }
                
                // Modos de Acesso
                Section("Ambiente de Acesso") {
                    Toggle("Conta Teste / Demonstração", isOn: Binding(
                        get: { viewModel.profile.isMock },
                        set: { _ in viewModel.toggleMockMode() }
                    ))
                    
                    Button(action: {
                        viewModel.loginWithMockAccount()
                    }) {
                        Label("Restaurar Dados Simulados Padrão", systemImage: "arrow.counterclockwise")
                    }
                }
                
                // Sair
                Section {
                    Button(role: .destructive, action: {
                        viewModel.logout()
                    }) {
                        HStack {
                            Spacer()
                            Text("Sair da Conta gov.br")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Perfil")
        }
    }
    
    private var badgeColor: Color {
        switch viewModel.profile.accountLevel {
        case .ouro: return Color(UIColor.systemYellow)
        case .prata: return Color(UIColor.systemGray)
        case .bronze: return Color(UIColor.systemOrange)
        }
    }
}
