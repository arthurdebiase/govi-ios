import SwiftUI

public enum AvatarPart: String, CaseIterable, Identifiable {
    case background = "Fundo"
    case circle = "Globo"
    case stripe = "Faixa"
    case semiCircle = "Base"
    
    public var id: String { rawValue }
    
    public var title: String { rawValue }
}

public struct AgentEditorSheet: View {
    @Binding public var agent: GovBrAgent
    public let onSave: (GovBrAgent) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Step 1: Identity & Avatar
    @State private var name: String
    @State private var descriptionText: String
    @State private var colors: AgentColors
    @State private var activePart: AvatarPart = .background
    
    // Step 2: Instructions & Capabilities
    @State private var systemPrompt: String
    @State private var allowedCapabilities: Set<String>
    
    public init(agent: Binding<GovBrAgent>, onSave: @escaping (GovBrAgent) -> Void) {
        self._agent = agent
        self.onSave = onSave
        self._name = State(initialValue: agent.wrappedValue.name)
        self._descriptionText = State(initialValue: agent.wrappedValue.description)
        self._colors = State(initialValue: agent.wrappedValue.colors)
        self._systemPrompt = State(initialValue: agent.wrappedValue.systemPrompt)
        self._allowedCapabilities = State(initialValue: Set(agent.wrappedValue.allowedCapabilities))
    }
    
    public static let availablePalette: [(name: String, hex: String)] = [
        ("Verde Govi", "#009440"),
        ("Amarelo Ouro", "#FFCB00"),
        ("Azul Govi", "#302681"),
        ("Branco", "#FFFFFF"),
        ("Azul Claro", "#0284C7"),
        ("Esmeralda", "#059669"),
        ("Laranja", "#EA580C"),
        ("Vermelho", "#DC2626"),
        ("Roxo", "#7C3AED"),
        ("Rosa", "#DB2777"),
        ("Grafite", "#475569"),
        ("Preto", "#0F172A")
    ]
    
    private var currentColorForActivePart: String {
        switch activePart {
        case .background: return colors.background
        case .circle: return colors.circle
        case .stripe: return colors.stripe
        case .semiCircle: return colors.semiCircle
        }
    }
    
    private func updateCurrentPartColor(_ hex: String) {
        HapticManager.shared.selection()
        switch activePart {
        case .background:
            colors.background = hex
        case .circle:
            colors.circle = hex
        case .stripe:
            colors.stripe = hex
        case .semiCircle:
            colors.semiCircle = hex
        }
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // Section: Avatar Construction & Customization
                Section {
                    VStack(spacing: 16) {
                        // Large Avatar Preview
                        GoviAvatarView(colors: colors, size: 120)
                            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                            .padding(.top, 4)
                        
                        // Active Part Selection Pill
                        Picker("Parte do Avatar", selection: $activePart) {
                            ForEach(AvatarPart.allCases) { part in
                                Text(part.title).tag(part)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 4)
                        
                        // Horizontal Color Swatches
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Self.availablePalette, id: \.hex) { item in
                                    Button(action: {
                                        updateCurrentPartColor(item.hex)
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: item.hex))
                                                .frame(width: 38, height: 38)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(UIColor.separator), lineWidth: item.hex == "#FFFFFF" ? 1.0 : 0.5)
                                                )
                                            
                                            if currentColorForActivePart.uppercased() == item.hex.uppercased() {
                                                Circle()
                                                    .stroke(Color(UIColor.label), lineWidth: 3)
                                                    .frame(width: 46, height: 46)
                                            }
                                        }
                                        .frame(width: 48, height: 48)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(item.name)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        }
                        
                        // Reset to default button
                        Button(action: {
                            HapticManager.shared.impact(.light)
                            withAnimation(.spring) {
                                colors = .default
                            }
                        }) {
                            Text("Restaurar cores originais")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(UIColor.systemBlue))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                
                // Section: Nome e Identificação
                Section("Identificação") {
                    TextField("Nome do Agente", text: $name)
                        .font(.body)
                    
                    TextField("Descrição do propósito (opcional)", text: $descriptionText)
                        .font(.body)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                
                // Section: Transição para a Segunda Fase (Instruções e Ferramentas)
                Section {
                    NavigationLink {
                        AgentInstructionsView(
                            systemPrompt: $systemPrompt,
                            allowedCapabilities: $allowedCapabilities
                        )
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(UIColor.systemBlue))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "doc.text.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Instruções e Capacidades")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Text(systemPrompt.isEmpty ? "Configurar prompt do sistema" : "Prompt configurado • \(allowedCapabilities.count) ferramentas")
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                } footer: {
                    Text("Personalize as orientações de raciocínio da IA e as permissões de acesso aos serviços públicos.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(agent.name.isEmpty ? "Criar Agente" : "Editar Agente")
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
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveChanges() {
        var updated = agent
        updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.description = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.colors = colors
        updated.systemPrompt = systemPrompt
        updated.allowedCapabilities = Array(allowedCapabilities)
        
        agent = updated
        onSave(updated)
        HapticManager.shared.notification(.success)
    }
}

// MARK: - Página 2: Instruções e Capacidades
public struct AgentInstructionsView: View {
    @Binding public var systemPrompt: String
    @Binding public var allowedCapabilities: Set<String>
    
    public init(
        systemPrompt: Binding<String>,
        allowedCapabilities: Binding<Set<String>>
    ) {
        self._systemPrompt = systemPrompt
        self._allowedCapabilities = allowedCapabilities
    }
    
    public var body: some View {
        List {
            Section {
                TextEditor(text: $systemPrompt)
                    .frame(minHeight: 160)
                    .font(.body)
            } header: {
                Text("Instruções do Copilot (System Prompt)")
            } footer: {
                Text("Instrua como o agente deve raciocinar, responder e guiar o cidadão nas tarefas oficiais do gov.br.")
            }
            
            Section {
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
                        HStack(spacing: 12) {
                            Image(systemName: cap.systemImage)
                                .font(.body)
                                .foregroundStyle(Color(UIColor.systemBlue))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cap.name)
                                    .font(.body)
                                Text(cap.description)
                                    .font(.caption)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            } header: {
                Text("Capacidades Cívicas Habilitadas")
            } footer: {
                Text("Selecione quais integrações oficiais o agente tem autorização para consultar e sugerir.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Instruções e Ferramentas")
        .navigationBarTitleDisplayMode(.inline)
    }
}
