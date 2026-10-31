import Foundation
import SwiftUI

@MainActor
@Observable
public final class IntegrationsStore {
    public static let shared = IntegrationsStore()
    
    public var futureIntegrations: [FutureIntegration] = []
    
    public init() {
        self.futureIntegrations = [
            FutureIntegration(
                id: "integ-inss-presencial",
                title: "Agendamento Presencial de Perícia Médica",
                agency: "INSS",
                category: "Previdência & Benefícios",
                status: "Anotado pelo Govi IA",
                userPrompt: "Gostaria de agendar perícia presencial para benefício por incapacidade temporária",
                priority: "Alta"
            ),
            FutureIntegration(
                id: "integ-passaporte-pf",
                title: "Emissão de Passaporte e Taxa GRU",
                agency: "Polícia Federal",
                category: "Cidadania & Viagem",
                status: "Anotado pelo Govi IA",
                userPrompt: "Quero tirar meu passaporte novo e pagar a GRU pelo app",
                priority: "Alta"
            )
        ]
    }
    
    @discardableResult
    public func recordIntegration(
        title: String,
        agency: String,
        category: String,
        userPrompt: String,
        priority: String = "Alta"
    ) -> FutureIntegration {
        // Check if an integration for this title or prompt already exists
        if let existing = futureIntegrations.first(where: {
            $0.title.localizedCaseInsensitiveContains(title) ||
            $0.userPrompt.localizedCaseInsensitiveContains(userPrompt)
        }) {
            return existing
        }
        
        let newIntegration = FutureIntegration(
            title: title,
            agency: agency,
            category: category,
            status: "Anotado pelo Govi IA",
            requestedAt: Date(),
            userPrompt: userPrompt,
            priority: priority
        )
        futureIntegrations.insert(newIntegration, at: 0)
        HapticManager.shared.notification(.success)
        return newIntegration
    }
    
    public func removeIntegration(_ item: FutureIntegration) {
        futureIntegrations.removeAll { $0.id == item.id }
        HapticManager.shared.impact(.light)
    }
}
