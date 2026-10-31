import SwiftUI

public struct ScreensCatalogView: View {
    @State private var selectedCategory: String = "Todos"
    @State private var selectedScreen: ScreenItem?
    
    private let categories = ["Todos", "Previdência", "Trânsito", "Receita Federal", "MEI", "Trabalho"]
    
    private let allScreens: [ScreenItem] = [
        ScreenItem(id: 101, name: "Tela Inicial gov.br", flow: "Acesso Geral", order: 1, imageUrl: "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=600&auto=format&fit=crop&q=80", altText: "Menu inicial com serviços mais acessados do cidadão"),
        ScreenItem(id: 201, name: "Extrato CNIS de Contribuições", flow: "Meu INSS", order: 2, imageUrl: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=600&auto=format&fit=crop&q=80", altText: "Histórico detalhado de recolhimentos previdenciários"),
        ScreenItem(id: 202, name: "Simulação de Aposentadoria", flow: "Meu INSS", order: 3, imageUrl: "https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=600&auto=format&fit=crop&q=80", altText: "Cálculo de pontos e regras de transição"),
        ScreenItem(id: 301, name: "Painel de Veículos e CRLV-e", flow: "CDT / Detran", order: 4, imageUrl: "https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600&auto=format&fit=crop&q=80", altText: "Carteira Digital de Trânsito com documento do veículo"),
        ScreenItem(id: 302, name: "Detalhamento do IPVA", flow: "CDT / Detran", order: 5, imageUrl: "https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=600&auto=format&fit=crop&q=80", altText: "Guia de cota única com código Pix e desconto"),
        ScreenItem(id: 401, name: "Certidão Negativa CND", flow: "Receita Federal", order: 6, imageUrl: "https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600&auto=format&fit=crop&q=80", altText: "Emissão de comprovante de regularidade fiscal"),
        ScreenItem(id: 501, name: "Emissão de Guia DAS-MEI", flow: "PGMEI Simples", order: 7, imageUrl: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600&auto=format&fit=crop&q=80", altText: "Geração de boleto mensal com chave Pix"),
        ScreenItem(id: 601, name: "Carteira de Trabalho Digital", flow: "Ministério do Trabalho", order: 8, imageUrl: "https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600&auto=format&fit=crop&q=80", altText: "Contratos de trabalho ativos e seguro-desemprego")
    ]
    
    public init() {}
    
    public var filteredScreens: [ScreenItem] {
        if selectedCategory == "Todos" {
            return allScreens
        }
        return allScreens.filter { screen in
            guard let flow = screen.flow else { return false }
            return flow.localizedCaseInsensitiveContains(selectedCategory)
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Category Filter Capsule Row (Apple HIG)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = cat
                                    }
                                }) {
                                    Text(cat)
                                        .font(.subheadline)
                                        .fontWeight(selectedCategory == cat ? .semibold : .regular)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? Color(UIColor.label) : Color(UIColor.secondarySystemGroupedBackground))
                                        .foregroundStyle(selectedCategory == cat ? Color(UIColor.systemBackground) : Color(UIColor.label))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(UIColor.separator), lineWidth: selectedCategory == cat ? 0 : 0.8)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    
                    // Grid of Mapped Official Screens
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                        ForEach(filteredScreens) { screen in
                            Button(action: {
                                HapticManager.shared.impact(.light)
                                selectedScreen = screen
                            }) {
                                VStack(alignment: .leading, spacing: 6) {
                                    AsyncImage(url: URL(string: screen.displayUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(height: 180)
                                                .frame(maxWidth: .infinity)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 180)
                                                .clipped()
                                        case .failure:
                                            VStack(spacing: 4) {
                                                Image(systemName: "photo")
                                                    .font(.title)
                                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                                Text(screen.name)
                                                    .font(.caption2)
                                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                            }
                                            .frame(height: 180)
                                            .frame(maxWidth: .infinity)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .background(Color(UIColor.secondarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color(UIColor.separator), lineWidth: 0.8)
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(screen.name)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(Color(UIColor.label))
                                            .lineLimit(1)
                                        
                                        if let flow = screen.flow {
                                            Text(flow)
                                                .font(.caption2)
                                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90) // clearance for floating tab bar
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Telas Oficiais")
            .sheet(item: $selectedScreen) { screen in
                ScreenGallerySheet(screens: [screen])
            }
        }
    }
}
