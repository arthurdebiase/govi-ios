import SwiftUI

public struct InviteSheet: View {
    public let userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    @State private var invite: EphemeralInvite
    @State private var timeRemaining: Int
    @State private var timerActive: Bool = true
    @State private var isCopied: Bool = false
    
    public init(userProfile: UserProfile) {
        self.userProfile = userProfile
        let newInvite = EphemeralInvite(
            senderId: MatrixUserId.fromCpf(userProfile.cpf).rawValue,
            senderDisplayName: userProfile.name,
            senderAccountLevel: userProfile.accountLevel,
            durationSeconds: 60
        )
        self._invite = State(initialValue: newInvite)
        self._timeRemaining = State(initialValue: 60)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 40))
                            .foregroundStyle(Color(UIColor.systemGreen))
                        
                        Text("Convite Cívico Seguro")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(UIColor.label))
                        
                        Text("Inicie uma conversa privada sem expor seu CPF. Este link utiliza criptografia Matrix e expira após o uso.")
                            .font(.subheadline)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    
                    // QR Code Card
                    VStack(spacing: 16) {
                        if timeRemaining > 0 {
                            Image(uiImage: QRCodeGenerator.generateQRCode(from: invite.inviteURL.absoluteString, size: 200))
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .padding(16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "clock.badge.exclamationmark")
                                    .font(.system(size: 48))
                                    .foregroundStyle(Color(UIColor.systemOrange))
                                Text("Convite Expirado")
                                    .font(.headline)
                                    .foregroundStyle(Color(UIColor.label))
                                Text("Por segurança, o link de 60 segundos foi invalidado.")
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                            }
                            .frame(width: 200, height: 200)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        
                        // Countdown Timer Badge
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundStyle(timeRemaining > 15 ? Color(UIColor.systemBlue) : Color(UIColor.systemRed))
                            
                            if timeRemaining > 0 {
                                Text("Expira em \(timeRemaining)s")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(timeRemaining > 15 ? Color(UIColor.systemBlue) : Color(UIColor.systemRed))
                            } else {
                                Text("Tempo Esgotado")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(UIColor.systemRed))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.secondarySystemFill))
                        .clipShape(Capsule())
                    }
                    
                    // Link & Actions Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                            Text(invite.inviteURL.absoluteString)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundStyle(Color(UIColor.label))
                                .lineLimit(1)
                            Spacer()
                            if isCopied {
                                Text("Copiado!")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(UIColor.systemGreen))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        HStack(spacing: 12) {
                            Button(action: copyLink) {
                                Label("Copiar Link", systemImage: "doc.on.doc.fill")
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 44)
                            }
                            .buttonStyle(.bordered)
                            .disabled(timeRemaining <= 0)
                            
                            ShareLink(item: invite.inviteURL) {
                                Label("Compartilhar", systemImage: "square.and.arrow.up.fill")
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(timeRemaining <= 0)
                        }
                        
                        Button(action: regenerateInvite) {
                            Label("Gerar Novo Link (60s)", systemImage: "arrow.clockwise")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Conexão Segura")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            while timerActive && timeRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    if timeRemaining == 15 {
                        HapticManager.shared.notification(.warning)
                    }
                }
            }
        }
    }
    
    private func copyLink() {
        UIPasteboard.general.string = invite.inviteURL.absoluteString
        HapticManager.shared.notification(.success)
        withAnimation {
            isCopied = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation {
                isCopied = false
            }
        }
    }
    
    private func regenerateInvite() {
        let newInvite = EphemeralInvite(
            senderId: MatrixUserId.fromCpf(userProfile.cpf).rawValue,
            senderDisplayName: userProfile.name,
            senderAccountLevel: userProfile.accountLevel,
            durationSeconds: 60
        )
        self.invite = newInvite
        self.timeRemaining = 60
        self.timerActive = true
        HapticManager.shared.impact(.medium)
    }
}
