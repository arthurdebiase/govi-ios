import SwiftUI

public struct ChatInputBarView: View {
    @Binding public var text: String
    public let isLoading: Bool
    public let onSend: () -> Void
    public let onQuickAction: (String) -> Void
    
    public init(
        text: Binding<String>,
        isLoading: Bool,
        onSend: @escaping () -> Void,
        onQuickAction: @escaping (String) -> Void
    ) {
        self._text = text
        self.isLoading = isLoading
        self.onSend = onSend
        self.onQuickAction = onQuickAction
    }
    
    public var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Native Apple Messages '+' button with quick tools Menu
            Menu {
                Button {
                    onQuickAction("Emitir minha guia do DAS do MEI com Pix")
                } label: {
                    Label("Guia DAS-MEI (Pix)", systemImage: "banknote")
                }
                
                Button {
                    onQuickAction("Emitir certidão negativa de débitos federais")
                } label: {
                    Label("Certidão Negativa (CND)", systemImage: "doc.text")
                }
                
                Button {
                    onQuickAction("Consultar débitos e IPVA do veículo")
                } label: {
                    Label("Consultar IPVA e Veículo", systemImage: "car.fill")
                }
                
                Button {
                    onQuickAction("Simular minha aposentadoria no Meu INSS")
                } label: {
                    Label("Simulação de Aposentadoria", systemImage: "heart.text.square")
                }
                
                Divider()
                
                Button {
                    onQuickAction("Como acessar os serviços com conta Prata ou Ouro?")
                } label: {
                    Label("Níveis de Conta gov.br", systemImage: "person.badge.shield.checkmark")
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
            }
            .accessibilityLabel("Ferramentas e Ações Rápidas")
            
            // Text Input Capsule (Native Apple Messages style)
            HStack(spacing: 8) {
                TextField("Mensagem para o Govi", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                
                // Mic or dictation placeholder if empty, send button if typed
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: {
                        onSend()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(UIColor.systemBlue))
                    }
                    .padding(.trailing, 4)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(UIColor.separator), lineWidth: 0.6)
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Divider()
                .background(Color(UIColor.separator)),
            alignment: .top
        )
    }
}
