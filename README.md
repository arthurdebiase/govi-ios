# Govi iOS (`govi.chat`)

**Govi iOS** é a versão 100% nativa em **SwiftUI** do Copilot de Inteligência Artificial para serviços públicos brasileiros (**gov.br**).

Desenvolvido rigorosamente sob as diretrizes do **Apple Human Interface Guidelines (HIG)** e inspirado na experiência visual e tátil do **Apple Mensagens (iMessage)**, o app dispensa qualquer componente customizado ou "hacks", utilizando exclusivamente APIs nativas do iOS.

---

## 🏛️ Pilares & Funcionalidades

1. **Experiência Mensagens (Apple Messages Style)**:
   - **Lista de Conversas:** Navegação nativa com `NavigationStack`, busca no drawer (`.searchable`), filtro segmented (`Todos`, `Agentes Virtuais`, `Atendentes Oficiais`), conversas fixadas e ações de deslizar (`.swipeActions`) para fixar, silenciar e apagar.
   - **Tela de Chat:** Balões contínuos nativos (`Color(UIColor.systemBlue)` e `Color(UIColor.secondarySystemBackground)`), botão `+` com `Menu` de atalhos gov.br, entrada de texto expansível em cápsula e feedback háptico (`UIImpactFeedbackGenerator`).

2. **Agentes Virtuais (IA) & Atendentes Oficiais Homologados**:
   - **Govi (Padrão):** Navegação integrada, níveis de conta (Prata/Ouro) e orientação de serviços.
   - **MEI & Tributos:** Emissão de guia DAS-MEI, declaração anual e certidões.
   - **Previdência & Benefícios:** Extrato CNIS, Meu INSS, FGTS e simulação de aposentadoria.
   - **Trânsito & Veículos:** Carteira Digital de Trânsito (CDT), CRLV-e, IPVA e licenciamento.
   - **Trabalho & Cidadão:** Carteira de Trabalho Digital, seguro-desemprego e PIS.
   - **Atendentes Oficiais:** Atendimento com servidores públicos reais homologados (Auditores da Receita, INSS, Detran).

3. **Cartões Interativos Nativos (Action Cards)**:
   - **Guia DAS-MEI:** Valor, vencimento e botão com cópia instantânea do Pix Copia e Cola.
   - **Certidão CND:** Situação cadastral REGULAR e atalho para visualização de autenticidade.
   - **Relatório de Veículo:** Detalhamento de IPVA, multas e pagamento de cota única via Pix.

4. **Guias Visuais com Telas Reais do gov.br**:
   - Carrossel paginado nativo com `TabView` apresentando telas reais capturadas dos aplicativos oficiais (INSS, CDT, Receita).

5. **Cartão de Contato Oficial (Contact Details Sheet)**:
   - Apresentação nativa via `.sheet` com `.presentationDetents([.medium, .large])`, foto em destaque, atalhos de ação rápida e lista de capacidades e garantias de segurança.

6. **Motor Híbrido & Soberano (Online / Offline)**:
   - Conexão em tempo real com o backend Govi (`/api/govbr-ia/chat`).
   - Fallback instantâneo para o motor determinístico offline, garantindo funcionamento completo mesmo sem conexão ou com o servidor local desligado.

---

## 🛠️ Tecnologias & Requisitos

- **Linguagem:** Swift 6.2+
- **Framework:** SwiftUI & Foundation
- **Design System:** Apple HIG (100% Nativo, Zero Custom Hacks)
- **Plataforma Mínima:** iOS 18.0+
- **IDE:** Xcode 16+ / Xcode 26+

---

## 🚀 Como Executar

### Abrir no Xcode

Abra o diretório diretamente no Xcode:

```bash
cd /Users/arthurdebiase/Documents/Projects/govi-ios
xed .
```

### Compilar via Linha de Comando (iOS Simulator)

```bash
xcodebuild -scheme Govi -destination "generic/platform=iOS Simulator"
```

### Executar Testes Automatizados

```bash
xcodebuild test -scheme Govi -destination "platform=iOS Simulator,name=iPhone 17"
```

---

## 📂 Estrutura do Projeto

```
Sources/Govi/
├── App/
│   └── GoviApp.swift                  # Entry point @main
├── Models/
│   ├── ActionCard.swift               # Cards de Pix, DAS, CND e Veículos
│   ├── Agent.swift                    # Agentes virtuais e capacidades
│   ├── Conversation.swift             # Conversas, parceiros e histórico
│   ├── Message.swift                  # Mensagens e timestamps
│   ├── ScreenItem.swift               # Telas mapeadas dos apps gov.br
│   ├── GovService.swift               # Catálogo de serviços integrados
│   └── UserProfile.swift              # Conta gov.br do cidadão
├── Services/
│   ├── GoviAPIService.swift           # Cliente HTTP e simulador offline
│   └── HapticManager.swift            # Gerenciador de vibrações hápticas
├── ViewModels/
│   ├── ConversationsViewModel.swift   # Filtros, ordenação e conversas fixadas
│   ├── ChatViewModel.swift            # Gestão do chat ativo e envio
│   ├── ProfileViewModel.swift         # Troca de contas e nível gov.br
│   └── MarketplaceViewModel.swift     # Gestão dos apps integrados
└── Views/
    ├── Conversations/
    │   ├── ConversationListView.swift # Lista master estilo Mensagens
    │   ├── ConversationRowView.swift  # Linha com avatar, badges e swipe
    │   └── AgentAvatarView.swift      # Avatar circular com status online
    ├── Chat/
    │   ├── ChatDetailView.swift       # Conversa com navegação inline
    │   ├── MessageBubbleView.swift    # Balões estilo iMessage
    │   ├── ChatInputBarView.swift     # Barra de entrada com botão '+' e Menu
    │   ├── ActionCardView.swift       # Cards interativos (DAS, CND, IPVA)
    │   ├── SuggestedActionsView.swift # Sugestões contextuais em chips
    │   └── ScreenGallerySheet.swift   # Visualizador de telas com paginação
    └── Sheets/
        ├── ContactDetailsSheet.swift  # Cartão de contato do agente
        ├── AgentEditorSheet.swift     # Editor de instruções em Form/Section
        ├── ProfileSheet.swift         # Perfil gov.br e dados cívicos
        └── MarketplaceSheet.swift     # Conexões gov.br com Toggles
```
