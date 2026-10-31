import SwiftUI

public struct ScreenGallerySheet: View {
    public let screens: [ScreenItem]
    @State public var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    public init(screens: [ScreenItem], initialIndex: Int = 0) {
        self.screens = screens
        self._selectedIndex = State(initialValue: initialIndex)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !screens.isEmpty {
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(screens.enumerated()), id: \.element.id) { index, screen in
                            VStack(spacing: 16) {
                                // Screen Image
                                AsyncImage(url: URL(string: screen.displayUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(Color(UIColor.separator), lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)
                                    case .failure:
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.badge.exclamationmark")
                                                .font(.largeTitle)
                                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                            Text("Não foi possível carregar a imagem da tela oficial.")
                                                .font(.caption)
                                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                                
                                // Description & Step Info
                                VStack(spacing: 4) {
                                    Text(screen.name)
                                        .font(.headline)
                                        .foregroundStyle(Color(UIColor.label))
                                        .multilineTextAlignment(.center)
                                    
                                    if let flow = screen.flow {
                                        Text("Fluxo: \(flow)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color(UIColor.secondaryLabel))
                                    }
                                    
                                    if let alt = screen.altText {
                                        Text(alt)
                                            .font(.caption)
                                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                                            .padding(.horizontal, 32)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding(.bottom, 24)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Telas Oficiais gov.br")
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
    }
}
