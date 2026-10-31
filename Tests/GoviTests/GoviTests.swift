import Testing
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
}
