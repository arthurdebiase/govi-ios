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
    
    // Step navigation
    @State private var currentStep: Int
    
    // Step 1: Apps selection
    @State private var selectedAppIds: Set<String>
    
    // Step 2: Identity & Avatar
    @State private var name: String
    @State private var descriptionText: String
    @State private var colors: AgentColors
    @State private var activePart: AvatarPart = .background
    
    // Step 3: Instructions & Capabilities
    @State private var systemPrompt: String
    @State private var allowedCapabilities: Set<String>
    
    public init(agent: Binding<GovBrAgent>, onSave: @escaping (GovBrAgent) -> Void) {
        self._agent = agent
        self.onSave = onSave
        let isNew = agent.wrappedValue.name.isEmpty || agent.wrappedValue.name == "Meu Agente IA"
        self._currentStep = State(initialValue: isNew ? 1 : 2)
        self._selectedAppIds = State(initialValue: Set(["inss", "receita", "mei"]))
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
    
    private var selectedApps: [GovAppOption] {
        GovAppOption.defaultApps.filter { selectedAppIds.contains($0.id) }
    }
    
    private func generateSmartPromptAndName() {
        let apps = selectedApps
        guard !apps.isEmpty else { return }
        
        // 1. Sugestão automática de Nome
        if name.isEmpty || name == "Meu Agente IA" || name.starts(with: "Especialista") || name.starts(with: "Copiloto") {
            if apps.count == 1 {
                name = "Especialista \(apps[0].shortName)"
                descriptionText = apps[0].description
            } else if apps.count == 2 {
                name = "\(apps[0].shortName) & \(apps[1].shortName)"
                descriptionText = "Copiloto para \(apps[0].name) e \(apps[1].name)"
            } else {
                name = "Copiloto Cidadão"
                descriptionText = "Assistente integrado a \(apps.count) serviços gov.br"
            }
        }
        
        // 2. Construção do Prompt Inteligente com Skills
        var promptLines: [String] = []
        promptLines.append("Você é um agente virtual gov.br personalizado, atuando como copiloto para os serviços digitais do cidadão brasileiro.")
        promptLines.append("\nServiços e Aplicativos Habilitados:")
        for app in apps {
            promptLines.append(app.skillsPromptSnippet)
        }
        
        promptLines.append("\nDiretrizes Operacionais do Agente:")
        promptLines.append("1. Responda com clareza, empatia e objetividade, orientando sempre com base nas regras oficiais vigentes.")
        promptLines.append("2. Para guias e pagamentos (ex.: DAS-MEI, IPVA), priorize fornecer os dados estruturados e código Pix para quitação instantânea.")
        promptLines.append("3. Para certidões e comprovantes (CND, CRLV-e, CNIS), oriente a emissão e validação imediata do documento.")
        promptLines.append("4. CASO O CIDADÃO SOLICITE UMA AÇÃO OU INTEGRAÇÃO EXTERNA AINDA NÃO DISPONÍVEL (ex.: agendamento presencial específico, emissão de passaporte físico, cancelamento de multas, transação bancária privada): anote proativamente a demanda na tabela de integrações para o futuro e oriente o cidadão com o canal oficial do órgão.")
        
        systemPrompt = promptLines.joined(separator: "\n")
        
        // 3. Capacidades habilitadas por padrão
        allowedCapabilities = [
            "Consultar acervo de telas e fluxos",
            "Simular etapas no aplicativo",
            "Emissão de certidões e comprovantes (PDF)",
            "Ações financeiras (Pix, boletos e taxas)"
        ]
    }
    
    public var body: some View {
        NavigationStack {
            if currentStep == 1 {
                appsSelectionStepView
            } else {
                identityAndAvatarStepView
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Passo 1: Seleção de Apps e Serviços (Estilo Image 2)
    private var appsSelectionStepView: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    // Top header decorativo com mini ícones dos apps selecionados
                    HStack(spacing: 6) {
                        ForEach(Array(selectedApps.prefix(4))) { app in
                            Circle()
                                .fill(Color(hex: app.iconBgColor))
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Image(systemName: app.systemImage)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.white)
                                )
                        }
                        if selectedApps.count > 4 {
                            Circle()
                                .fill(Color(UIColor.secondarySystemFill))
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Text("+\(selectedApps.count - 4)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(Color(UIColor.label))
                                )
                        }
                    }
                    .padding(.top, 8)
                    
                    // Título Principal e Subtítulo
                    VStack(spacing: 8) {
                        Text("Quais serviços você mais usa?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(UIColor.label))
                            .multilineTextAlignment(.center)
                        
                        Text("Selecione os apps do gov.br que você tem acesso. Vamos sugerir o prompt e as skills ideais para o seu agente.")
                            .font(.subheadline)
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Grid 3 colunas (estilo Image 2)
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(GovAppOption.defaultApps) { app in
                            let isSelected = selectedAppIds.contains(app.id)
                            Button {
                                HapticManager.shared.selection()
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    if isSelected {
                                        selectedAppIds.remove(app.id)
                                    } else {
                                        selectedAppIds.insert(app.id)
                                    }
                                }
                            } label: {
                                VStack(spacing: 10) {
                                    ZStack(alignment: .topTrailing) {
                                        // App Icon Container
                                        Circle()
                                            .fill(Color(hex: app.iconBgColor).opacity(0.16))
                                            .frame(width: 46, height: 46)
                                            .overlay(
                                                Image(systemName: app.systemImage)
                                                    .font(.system(size: 22, weight: .semibold))
                                                    .foregroundStyle(Color(hex: app.iconBgColor))
                                            )
                                        
                                        // Checkmark badge when selected
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color(UIColor.label))
                                                .background(Circle().fill(Color(UIColor.systemBackground)).padding(2))
                                                .offset(x: 6, y: -6)
                                        }
                                    }
                                    .padding(.top, 4)
                                    
                                    Text(app.name)
                                        .font(.caption)
                                        .fontWeight(isSelected ? .bold : .medium)
                                        .foregroundStyle(Color(UIColor.label))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.85)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 108)
                                .padding(.horizontal, 6)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(
                                            isSelected ? Color(UIColor.label) : Color(UIColor.separator).opacity(0.6),
                                            lineWidth: isSelected ? 2.0 : 0.6
                                        )
                                )
                                .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.02), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Bottom spacer for floating button
                    Color.clear.frame(height: 90)
                }
                .padding(.vertical, 12)
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            // Botão Inferior Flutuante "Continuar" (Estilo Image 2)
            VStack {
                Button {
                    HapticManager.shared.impact(.medium)
                    generateSmartPromptAndName()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        currentStep = 2
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(selectedAppIds.isEmpty ? "Selecione ao menos 1 serviço" : "Continuar (\(selectedAppIds.count))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(UIColor.systemBackground))
                        Spacer()
                    }
                    .frame(height: 52)
                    .background(selectedAppIds.isEmpty ? Color(UIColor.systemGray4) : Color(UIColor.label))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.12), radius: 10, y: 4)
                }
                .disabled(selectedAppIds.isEmpty)
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("Passo 1 de 2")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Passo 2: Identificação & Avatar (Estilo Image 1)
    private var identityAndAvatarStepView: some View {
        List {
            // Resumo dos Apps Escolhidos (Permite voltar e alterar)
            Section {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        currentStep = 1
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .foregroundStyle(Color(UIColor.systemBlue))
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(selectedAppIds.count) Serviços Habilitados")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(UIColor.label))
                            
                            Text(selectedApps.map { $0.shortName }.joined(separator: " • "))
                                .font(.caption2)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Text("Alterar")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(UIColor.systemBlue))
                        
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
            } header: {
                Text("Base de Conhecimento e Ferramentas")
            }
            
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
                        allowedCapabilities: $allowedCapabilities,
                        selectedApps: selectedApps
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
                            
                            Text("Prompt sugerido para \(selectedAppIds.count) apps • \(allowedCapabilities.count) ferramentas")
                                .font(.caption)
                                .foregroundStyle(Color(UIColor.secondaryLabel))
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 2)
                }
            } footer: {
                Text("O prompt inicial e as habilidades foram pré-configurados com base nos apps selecionados. Você pode personalizar as instruções a qualquer momento.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(agent.name.isEmpty ? "Personalizar Agente" : "Editar Agente")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        currentStep = 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Apps")
                    }
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

// MARK: - Página 3: Instruções e Capacidades
public struct AgentInstructionsView: View {
    @Binding public var systemPrompt: String
    @Binding public var allowedCapabilities: Set<String>
    public var selectedApps: [GovAppOption] = []
    
    public init(
        systemPrompt: Binding<String>,
        allowedCapabilities: Binding<Set<String>>,
        selectedApps: [GovAppOption] = []
    ) {
        self._systemPrompt = systemPrompt
        self._allowedCapabilities = allowedCapabilities
        self.selectedApps = selectedApps
    }
    
    public var body: some View {
        List {
            if !selectedApps.isEmpty {
                Section {
                    ForEach(selectedApps) { app in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: app.iconBgColor).opacity(0.16))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: app.systemImage)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color(hex: app.iconBgColor))
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(UIColor.label))
                                
                                Text(app.description)
                                    .font(.caption2)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    Text("Skills dos Apps Conectados (\(selectedApps.count))")
                } footer: {
                    Text("O prompt do sistema inclui o conhecimento específico desses serviços para guiar o cidadão.")
                }
            }
            
            Section {
                TextEditor(text: $systemPrompt)
                    .frame(minHeight: 180)
                    .font(.subheadline)
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
