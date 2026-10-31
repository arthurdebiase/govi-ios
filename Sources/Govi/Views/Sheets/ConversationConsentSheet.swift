import SwiftUI

public struct ConversationConsentSheet: View {
    public let request: ConversationRequest
    public let userProfile: UserProfile
    public let onAccept: (SelectiveDisclosurePermissions) -> Void
    public let onDecline: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var permissions = SelectiveDisclosurePermissions()
    
    public init(
        request: ConversationRequest,
        userProfile: UserProfile,
        onAccept: @escaping (SelectiveDisclosurePermissions) -> Void,
        onDecline: @escaping () -> Void
    ) {
        self.request = request
        self.userProfile = userProfile
        self.onAccept = onAccept
        self.onDecline = onDecline
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Requester Header Section
                Section {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color(UIColor.secondarySystemFill))
                            .frame(width: 72, height: 72)
                            .overlay(
                                Text(request.senderInitials)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(UIColor.label))
                            )
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Text(request.senderDisplayName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(Color(UIColor.systemGreen))
                            }
                            
                            Text("Identidade gov.br Nível \(request.senderAccountLevel.rawValue) Verificada")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(UIColor.systemGreen))
                            
                            Text(request.introMessage)
                                .font(.subheadline)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                // Selective Disclosure Permissions Section
                Section(header: Text("Informações que você autoriza compartilhar"), footer: Text("Você mantém o controle total. O seu CPF real nunca será revelado.")) {
                    
                    Toggle(isOn: $permissions.shareFullName) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nome Completo")
                                .font(.subheadline)
                            Text(permissions.shareFullName ? userProfile.name : "\(userProfile.name.components(separatedBy: " ").first ?? "Cidadão") (Pseudônimo)")
                                .font(.caption)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                    }
                    
                    Toggle(isOn: $permissions.shareGovBrVerificationBadge) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Selo de Autenticidade gov.br")
                                .font(.subheadline)
                            Text("Comprova que você possui conta \(userProfile.accountLevel.rawValue)")
                                .font(.caption)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                    }
                    
                    Toggle(isOn: $permissions.shareMaskedCpf) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CPF Mascarado")
                                .font(.subheadline)
                            Text(userProfile.maskedCpf)
                                .font(.caption)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                        }
                    }
                    
                    if let vehicle = userProfile.vehicles.first {
                        Toggle(isOn: $permissions.shareVehiclePlate) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Veículo Vinculado")
                                    .font(.subheadline)
                                Text("\(vehicle.modelo) • Placa \(vehicle.placa)")
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                            }
                        }
                    }
                    
                    if let cnpj = userProfile.cnpj {
                        Toggle(isOn: $permissions.shareCnpjMei) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("CNPJ MEI")
                                    .font(.subheadline)
                                Text(cnpj)
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                            }
                        }
                    }
                }
                
                // Action Buttons
                Section {
                    Button(action: {
                        HapticManager.shared.notification(.success)
                        dismiss()
                        onAccept(permissions)
                    }) {
                        HStack {
                            Spacer()
                            Label("Autorizar e Iniciar Conversa", systemImage: "checkmark.circle.fill")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .frame(minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    Button(role: .destructive, action: {
                        HapticManager.shared.notification(.warning)
                        dismiss()
                        onDecline()
                    }) {
                        HStack {
                            Spacer()
                            Text("Recusar Solicitação")
                                .foregroundStyle(Color(UIColor.systemRed))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Solicitação de Conversa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
