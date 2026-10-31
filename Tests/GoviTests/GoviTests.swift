import Testing
import Foundation
@testable import Govi

struct GoviTests {
    @Test func testDefaultAgentsCount() async throws {
        let agents = GovBrAgent.defaultAgents
        #expect(agents.count >= 5)
        #expect(agents.first?.id == "govbr-default")
    }
    
    @Test func testConversationsFiltering() async throws {
        await MainActor.run {
            let vm = ConversationsViewModel()
            #expect(!vm.conversations.isEmpty)
            
            // Test filter by agent
            vm.selectedFilter = .agent
            #expect(vm.filteredConversations.allSatisfy { $0.type == "agent" })
            
            // Test filter by person
            vm.selectedFilter = .person
            #expect(vm.filteredConversations.allSatisfy { $0.type == "person" })
        }
    }
    
    @Test func testChatServiceExecution() async throws {
        let service = GoviAPIService()
        let agent = GovBrAgent.defaultAgents[0]
        let profile = UserProfile()
        
        let result = await service.sendChatMessage(
            text: "Emitir DAS do MEI com Pix",
            history: [],
            agent: agent,
            userProfile: profile
        )
        
        #expect(!result.reply.isEmpty)
        #expect(result.actionCard != nil || !result.suggestedActions.isEmpty)
    }
    
    @Test func testMatrixSovereignProtocol() async throws {
        let matrixService = MatrixService()
        
        // 1. Test Matrix User ID generation from CPF
        let userId = MatrixUserId.fromCpf("123.842.198-00", domain: "cidadao.gov.br")
        #expect(userId.rawValue == "@12384219800:cidadao.gov.br")
        
        // 2. Test User Authentication via gov.br
        let session = await matrixService.authenticateWithGovBr(
            cpf: "123.842.198-00",
            accountLevel: .ouro
        )
        #expect(session.userId == "@12384219800:cidadao.gov.br")
        #expect(session.e2eeStatus.isEncrypted == true)
        #expect(session.e2eeStatus.isCrossSigningVerified == true)
        #expect(session.e2eeStatus.algorithm == .megolm)
        
        // 3. Test Room Creation
        let roomId = await matrixService.createRoom(
            title: "Atendimento Receita Federal",
            invitee: "@camila.mendes:receita.gov.br"
        )
        #expect(roomId.hasPrefix("!room_atendimento_receita_federal_"))
        #expect(roomId.hasSuffix(":gov.br"))
        
        // 4. Test Cross-Signing Verification
        let isVerified = await matrixService.verifyPartnerCrossSigning(partnerId: "@camila.mendes:receita.gov.br")
        #expect(isVerified == true)
    }
    
    @Test func testEphemeralInviteAndSelectiveDisclosure() async throws {
        // 1. Test Ephemeral Invite generation & 60s window
        let invite = EphemeralInvite(
            senderId: "@arthur:cidadao.gov.br",
            senderDisplayName: "Arthur Debiase",
            durationSeconds: 60
        )
        #expect(!invite.isExpired)
        #expect(invite.inviteURL.absoluteString.contains("govi.chat/c/"))
        
        // 2. Test Selective Disclosure Permissions defaults
        let permissions = SelectiveDisclosurePermissions(
            shareFullName: false,
            shareGovBrVerificationBadge: true,
            shareMaskedCpf: false
        )
        #expect(permissions.shareFullName == false)
        #expect(permissions.shareGovBrVerificationBadge == true)
        #expect(permissions.shareMaskedCpf == false)
        
        // 3. Test Handshake & Acceptance via ViewModel
        await MainActor.run {
            let vm = ConversationsViewModel()
            #expect(!vm.pendingRequests.isEmpty)
            let request = vm.pendingRequests[0]
            
            let acceptedConv = vm.acceptConversationRequest(request, permissions: permissions)
            #expect(acceptedConv.personName == request.senderDisplayName)
            #expect(acceptedConv.isCrossSigningVerified == true)
            #expect(acceptedConv.isE2EEEncrypted == true)
            #expect(vm.pendingRequests.isEmpty)
        }
    }
}
