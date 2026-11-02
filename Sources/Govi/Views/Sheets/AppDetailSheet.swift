import SwiftUI

public struct AppDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    public let service: GovService
    public let isConnected: Bool
    public let onToggleConnection: () -> Void
    
    public init(
        service: GovService,
        isConnected: Bool,
        onToggleConnection: @escaping () -> Void
    ) {
        self.service = service
        self.isConnected = isConnected
        self.onToggleConnection = onToggleConnection
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Header: Ícone oficial grande e títulos
                    VStack(spacing: 14) {
                        AppIconView(
                            urlString: service.thumbnailUrl,
                            systemImage: service.systemImage,
                            fallbackBgColor: "#0284C7",
                            appName: service.name,
                            size: 84
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 10, y: 5)
                        
                        VStack(spacing: 6) {
                            Text(service.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(UIColor.label))
                                .multilineTextAlignment(.center)
                            
                            Text(service.organization)
                                .font(.subheadline)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                        }
                        
                        // Badges de Esfera e Categoria
                        HStack(spacing: 8) {
                            Text(service.sphere)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(sphereBadgeColor(for: service.sphere).opacity(0.15))
                                .foregroundStyle(sphereBadgeColor(for: service.sphere))
                                .clipShape(Capsule())
                            
                            Text(service.category)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(UIColor.secondarySystemFill))
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 10)
                    
                    // Card Informativo Estilo App Store
                    HStack(spacing: 0) {
                        VStack(spacing: 4) {
                            Text("AVALIAÇÃO")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color(UIColor.tertiaryLabel))
                            HStack(spacing: 3) {
                                Text(String(format: "%.1f", service.rating))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(UIColor.label))
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(UIColor.systemYellow))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(height: 32)
                        
                        VStack(spacing: 4) {
                            Text("ESFERA")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color(UIColor.tertiaryLabel))
                            Text(service.sphere)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(UIColor.label))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .frame(height: 32)
                        
                        VStack(spacing: 4) {
                            Text("DOWNLOADS")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color(UIColor.tertiaryLabel))
                            Text(service.downloads)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(UIColor.label))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    
                    // Seção de Descrição
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sobre o Serviço")
                            .font(.headline)
                            .foregroundStyle(Color(UIColor.label))
                        
                        Text(service.description)
                            .font(.body)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Ações de Conexão e Acesso Oficial
                    VStack(spacing: 12) {
                        Button {
                            HapticManager.shared.impact(.medium)
                            onToggleConnection()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isConnected ? "checkmark.circle.fill" : "plus.circle.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                Text(isConnected ? "Conectado ao Govi Copiloto" : "Conectar ao Copiloto")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(isConnected ? Color(UIColor.systemGreen) : Color(UIColor.label))
                            .foregroundStyle(Color(UIColor.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        
                        if let url = URL(string: service.officialUrl) {
                            Link(destination: url) {
                                HStack(spacing: 6) {
                                    Text("Acessar Portal Oficial")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                }
                                .foregroundStyle(Color(UIColor.systemBlue))
                                .frame(height: 38)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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
