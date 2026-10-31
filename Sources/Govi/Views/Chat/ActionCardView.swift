import SwiftUI

public struct ActionCardView: View {
    public let card: ActionCard
    public let onAction: (ActionCardButton) -> Void
    
    public init(card: ActionCard, onAction: @escaping (ActionCardButton) -> Void) {
        self.card = card
        self.onAction = onAction
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .top, spacing: 10) {
                iconView
                    .frame(width: 38, height: 38)
                    .background(statusBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.title)
                        .font(.headline)
                        .foregroundStyle(Color(UIColor.label))
                    
                    if let subtitle = card.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                }
                
                Spacer()
                
                statusBadgeView
            }
            
            Divider()
                .background(Color(UIColor.separator))
            
            // Key Data Grid / Details
            dataDetailsView
            
            // Action Buttons
            if let actions = card.actions, !actions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(actions) { actionButton in
                        Button(action: {
                            onAction(actionButton)
                        }) {
                            HStack {
                                Spacer()
                                if actionButton.action.contains("PIX") {
                                    Image(systemName: "doc.on.doc.fill")
                                } else if actionButton.action.contains("VIEW") {
                                    Image(systemName: "arrow.up.right.square.fill")
                                }
                                Text(actionButton.label)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .frame(minHeight: 44)
                        }
                        .buttonStyle(buttonStyle(for: actionButton.variant))
                    }
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(UIColor.separator), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch card.type {
        case .pixPayment:
            Image(systemName: "qrcode")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(UIColor.systemOrange))
        case .documentReady:
            Image(systemName: "doc.text.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(UIColor.systemGreen))
        case .vehicleReport:
            Image(systemName: "car.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(UIColor.systemBlue))
        case .debtStatus:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(UIColor.systemRed))
        case .identityBadge:
            Image(systemName: "person.badge.shield.checkmark.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(UIColor.systemYellow))
        }
    }
    
    private var statusBackgroundColor: Color {
        switch card.status {
        case .success: return Color(UIColor.systemGreen).opacity(0.15)
        case .warning: return Color(UIColor.systemOrange).opacity(0.15)
        case .pending: return Color(UIColor.systemBlue).opacity(0.15)
        case .info: return Color(UIColor.systemGray5)
        }
    }
    
    @ViewBuilder
    private var statusBadgeView: some View {
        switch card.status {
        case .success:
            Label("Concluído", systemImage: "checkmark.circle.fill")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.systemGreen).opacity(0.15))
                .foregroundStyle(Color(UIColor.systemGreen))
                .clipShape(Capsule())
        case .warning:
            Label("Pendente", systemImage: "clock.fill")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.systemOrange).opacity(0.15))
                .foregroundStyle(Color(UIColor.systemOrange))
                .clipShape(Capsule())
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var dataDetailsView: some View {
        VStack(spacing: 6) {
            ForEach(card.data.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                if !shouldHideKey(key) {
                    HStack(alignment: .top) {
                        Text(formatKey(key))
                            .font(.caption)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                        Spacer()
                        Text(value)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(UIColor.label))
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }
    
    private func shouldHideKey(_ key: String) -> Bool {
        return key.contains("pixCopiaECola") || key.contains("linhaDigitavel") || key.contains("tipo")
    }
    
    private func formatKey(_ key: String) -> String {
        switch key {
        case "valorFormatado", "valor": return "Valor"
        case "vencimento": return "Vencimento"
        case "contribuinte": return "Contribuinte"
        case "documento": return "Documento"
        case "situacao": return "Situação"
        case "codigoControle": return "Autenticidade"
        case "validade": return "Validade"
        case "placa": return "Placa"
        case "modelo": return "Modelo"
        case "totalDebitos": return "Total de Débitos"
        case "ipvaValor": return "IPVA"
        case "licenciamentoValor": return "Licenciamento"
        default: return key.capitalized
        }
    }
    
    private func buttonStyle(for variant: String?) -> some PrimitiveButtonStyle {
        if variant == "primary" {
            return AnyPrimitiveButtonStyle(.borderedProminent)
        } else {
            return AnyPrimitiveButtonStyle(.bordered)
        }
    }
}

private struct AnyPrimitiveButtonStyle: PrimitiveButtonStyle {
    private let makeBodyClosure: (Configuration) -> AnyView
    
    init<S: PrimitiveButtonStyle>(_ style: S) {
        self.makeBodyClosure = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        makeBodyClosure(configuration)
    }
}
