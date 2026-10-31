import Foundation
import SwiftUI

@MainActor
@Observable
public final class ProfileViewModel {
    public var profile: UserProfile
    public var isAuthenticated: Bool
    
    public init(profile: UserProfile = UserProfile(), isAuthenticated: Bool = true) {
        self.profile = profile
        self.isAuthenticated = isAuthenticated
    }
    
    public func setAccountLevel(_ level: GovBrAccountLevel) {
        profile.accountLevel = level
        HapticManager.shared.selection()
    }
    
    public func toggleMockMode() {
        profile.isMock.toggle()
        HapticManager.shared.impact(.medium)
    }
    
    public func logout() {
        isAuthenticated = false
        HapticManager.shared.notification(.warning)
    }
    
    public func loginWithMockAccount() {
        profile = UserProfile()
        isAuthenticated = true
        HapticManager.shared.notification(.success)
    }
}
