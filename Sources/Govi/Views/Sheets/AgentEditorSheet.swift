import SwiftUI

public struct AgentEditorSheet: View {
    @Binding public var agent: GovBrAgent
    public let onSave: (GovBrAgent) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var descriptionText: String
    @State private var systemPrompt: String
    @State private var avatarType: AgentAvatarType
    @State private var allowedCapabilities: Set<String>
    
    public init(agent: Binding<GovBrAgent>, onSave: @escaping (GovBrAgent) -> Void) {
        self._agent = agent
        self.onSave = onSave
        self._name = State(initialValue: agent.wrappedValue.name)
        self._descriptionText = State(initialValue: agent.wrappedValue.description)
        self._systemPrompt = State(initialValue: agent.wrappedValue.systemPrompt)
        self._avatarType = State(initialValue: agent.wrappedValue.avatarType)
        self._allowedCapabilities = State(initialValue: Set(agent.wrappedValue.allowedCapabilities))
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Identificação") {
                    TextField("Nome do Agente", text: $name)
                    TextField("Descrição rápida", text: $descriptionText)
                    
                    Picker("Ícone do Agente", selection: $avatarType) {
                        ForEach(AgentAvatarType.allCases, id: \.self) { type in
                            Label(type.rawValue.capitalized, systemImage: type.systemImageName)
                                .tag(type)
                        }
                    }
                }
                
                Section("Instruções do Copilot (System Prompt)") {
                    TextEditor(text: $systemPrompt)
                        .frame(minHeight: 120)
                }
                
                Section("Capacidades Habilitadas") {
                    ForEach(GovBrAgent.availableCapabilities) { cap in
                        Toggle(isOn: Binding(
                            get: { allowedCapabilities.contains(cap.id) },
                            set: { isEnabled in
                                if isEnabled {
                                    allowedCapabilities.insert(cap.id)
                                } else {
                                    allowedCapabilities.remove(cap.id)
                                }
                            }
                        )) {
                            Label(cap.name, systemImage: cap.systemImage)
                        }
                    }
                }
            }
            .navigationTitle("Editar Agente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveChanges() {
        var updated = agent
        updated.name = name
        updated.description = descriptionText
        updated.systemPrompt = systemPrompt
        updated.avatarType = avatarType
        updated.allowedCapabilities = Array(allowedCapabilities)
        
        agent = updated
        onSave(updated)
        HapticManager.shared.notification(.success)
    }
}
