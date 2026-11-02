import Foundation
import SwiftUI

@MainActor
@Observable
public final class GovernmentAppsStore {
    public static let shared = GovernmentAppsStore()
    
    public var apps: [GovernmentApp] = []
    public var connectedAppIds: Set<Int> = []
    public var isLoading: Bool = false
    
    private let connectedStorageKey = "govi_connected_service_ids"
    
    public init() {
        loadSavedConnections()
        loadLocalCatalog()
        Task {
            await syncWithRemoteBackend()
        }
    }
    
    // MARK: - Persistence of Connected Services
    private func loadSavedConnections() {
        if let saved = UserDefaults.standard.array(forKey: connectedStorageKey) as? [Int] {
            self.connectedAppIds = Set(saved)
        } else {
            // Default connected apps (popular federal services)
            self.connectedAppIds = Set([101, 102, 103, 104, 105, 106, 107, 108])
        }
    }
    
    public func toggleConnection(for appId: Int) {
        if connectedAppIds.contains(appId) {
            connectedAppIds.remove(appId)
        } else {
            connectedAppIds.insert(appId)
        }
        UserDefaults.standard.set(Array(connectedAppIds), forKey: connectedStorageKey)
        HapticManager.shared.impact(.light)
    }
    
    public func isConnected(_ appId: Int) -> Bool {
        connectedAppIds.contains(appId)
    }
    
    // MARK: - Local Catalog Loader (Instant 0ms)
    private func loadLocalCatalog() {
        var catalogData: Data?
        
        // 1. Try Bundle.main
        if let url = Bundle.main.url(forResource: "government_apps_catalog", withExtension: "json") {
            catalogData = try? Data(contentsOf: url)
        }
        
        // 2. Try Bundle(for: ...)
        if catalogData == nil {
            let bundle = Bundle(for: GovernmentAppsStoreSelfMarker.self)
            if let url = bundle.url(forResource: "government_apps_catalog", withExtension: "json") {
                catalogData = try? Data(contentsOf: url)
            }
        }
        
        // 3. Try /tmp fallback for simulator/development
        if catalogData == nil {
            let tmpUrl = URL(fileURLWithPath: "/tmp/government_apps_catalog.json")
            if FileManager.default.fileExists(atPath: tmpUrl.path) {
                catalogData = try? Data(contentsOf: tmpUrl)
            }
        }
        
        if let data = catalogData {
            do {
                let decoded = try JSONDecoder().decode([GovernmentApp].self, from: data)
                self.apps = decoded
                #if DEBUG
                print("[GovernmentAppsStore] Loaded \(decoded.count) official Brazilian government apps from local catalog.")
                #endif
                return
            } catch {
                #if DEBUG
                print("[GovernmentAppsStore] Error decoding catalog JSON: \(error)")
                #endif
            }
        }
        
        // 4. Hardcoded fallback if catalog file is unavailable
        self.apps = fallbackCatalog
    }
    
    // MARK: - Remote Backend Synchronization
    public func syncWithRemoteBackend() async {
        guard let url = URL(string: "http://127.0.0.1:5001/api/apps/catalog") else { return }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 4.0
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return }
            
            struct CatalogResponse: Codable {
                let apps: [GovernmentApp]
                let total: Int
            }
            
            let decoded = try JSONDecoder().decode(CatalogResponse.self, from: data)
            if !decoded.apps.isEmpty {
                self.apps = decoded.apps
                #if DEBUG
                print("[GovernmentAppsStore] Synced \(decoded.apps.count) apps from live web backend.")
                #endif
            }
        } catch {
            // Offline or web server down, silently keep bundled data
        }
    }
    
    // MARK: - Mappings for UI Views
    
    /// Converts catalog apps into GovAppOption models used in Agent Creation Step 1
    public var appOptions: [GovAppOption] {
        apps.map { app in
            let shortName = deriveShortName(from: app.name)
            let (systemImage, iconBgColor) = iconAndColor(for: app.category)
            let snippet = "• \(app.name): Especialista em serviços de \(app.category.lowercased()) (\(app.description)). Capacidade de guiar o cidadão nas etapas oficiais com precisão."
            
            return GovAppOption(
                id: String(app.id),
                slug: app.slug,
                name: app.name,
                shortName: shortName,
                category: app.category,
                sphere: app.sphere ?? "Federal",
                thumbnailUrl: app.thumbnailUrl,
                systemImage: systemImage,
                iconBgColor: iconBgColor,
                description: app.description,
                skillsPromptSnippet: snippet,
                rating: app.rating ?? 4.8,
                downloads: app.downloads ?? "+1M",
                popularRank: app.popularRank ?? 99,
                featured: app.featured ?? false
            )
        }
    }
    
    /// Converts catalog apps into GovService models used in the Marketplace / Conectar tab
    public var govServices: [GovService] {
        apps.map { app in
            let (systemImage, _) = iconAndColor(for: app.category)
            let isConnected = self.connectedAppIds.contains(app.id)
            let officialUrl = "https://www.gov.br"
            
            return GovService(
                id: app.id,
                slug: app.slug,
                name: app.name,
                category: app.category,
                sphere: app.sphere ?? "Federal",
                organization: app.organization ?? "Governo Federal",
                description: app.description,
                systemImage: systemImage,
                thumbnailUrl: app.thumbnailUrl,
                isConnected: isConnected,
                screenCount: app.screenCount ?? 12,
                officialUrl: officialUrl,
                rating: app.rating ?? 4.8,
                downloads: app.downloads ?? "+1M"
            )
        }
    }
    
    // MARK: - Helpers
    private func deriveShortName(from fullName: String) -> String {
        if fullName.contains("(") && fullName.contains(")") {
            if let start = fullName.firstIndex(of: "("), let end = fullName.firstIndex(of: ")") {
                let inside = fullName[fullName.index(after: start)..<end].trimmingCharacters(in: .whitespaces)
                if !inside.isEmpty && inside.count <= 10 {
                    return inside
                }
            }
        }
        let words = fullName.components(separatedBy: " ")
        if words.count <= 2 {
            return fullName
        }
        return "\(words[0]) \(words[1])"
    }
    
    private func iconAndColor(for category: String) -> (String, String) {
        switch category {
        case "Documentos":
            return ("doc.text.image.fill", "#0284C7")
        case "Trânsito":
            return ("car.fill", "#2563EB")
        case "Trabalho":
            return ("person.text.rectangle.fill", "#7C3AED")
        case "Finanças":
            return ("banknote.fill", "#059669")
        case "Saúde":
            return ("cross.case.fill", "#0D9488")
        case "Benefícios":
            return ("dollarsign.circle.fill", "#D97706")
        case "Cidadania":
            return ("person.badge.shield.checkmark.fill", "#4F46E5")
        case "Logística":
            return ("shippingbox.fill", "#EA580C")
        case "Segurança":
            return ("shield.fill", "#DC2626")
        case "Empresas":
            return ("briefcase.fill", "#10B981")
        case "Educação":
            return ("graduationcap.fill", "#6366F1")
        default:
            return ("app.fill", "#009440")
        }
    }
    
    private var fallbackCatalog: [GovernmentApp] {
        [
            GovernmentApp(
                id: 101,
                slug: "gov-br",
                name: "gov.br",
                description: "Identidade digital única, login oficial Ouro/Prata, certidões e assinatura digital soberana.",
                thumbnailUrl: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/d2/f3/a5/d2f3a52e-e4f4-4932-43de-a0e851f52971/AppIcon-0-0-1x_U007emarketing-0-11-0-85-220.png/512x512bb.jpg",
                category: "Documentos",
                sphere: "Federal",
                organization: "Ministério da Gestão e da Inovação / Serpro",
                rating: 4.8,
                downloads: "+100M",
                featured: true,
                popularRank: 1,
                screenCount: 12
            ),
            GovernmentApp(
                id: 102,
                slug: "carteira-digital-de-transito",
                name: "Carteira Digital de Trânsito (CDT)",
                description: "CNH digital válida em todo o Brasil, CRLV-e e pagamento de multas com até 40% de desconto.",
                thumbnailUrl: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/2f/84/5f/2f845ff9-2067-bb12-06d2-37654149c0f0/AppIcon-0-0-1x_U007emarketing-0-8-0-85-220.png/512x512bb.jpg",
                category: "Trânsito",
                sphere: "Federal",
                organization: "Senatran / Serpro",
                rating: 4.9,
                downloads: "+80M",
                featured: true,
                popularRank: 2,
                screenCount: 10
            ),
            GovernmentApp(
                id: 103,
                slug: "meu-inss",
                name: "Meu INSS",
                description: "Aposentadorias, extrato CNIS, agendamento de perícias e salário-maternidade.",
                thumbnailUrl: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/88/5d/16/885d16ac-2625-14f4-6938-11cb1f752b52/AppIcon-0-0-1x_U007emarketing-0-11-0-85-220.png/512x512bb.jpg",
                category: "Trabalho",
                sphere: "Federal",
                organization: "INSS / Dataprev",
                rating: 4.7,
                downloads: "+60M",
                featured: true,
                popularRank: 3,
                screenCount: 14
            )
        ]
    }
}

private final class GovernmentAppsStoreSelfMarker {}
