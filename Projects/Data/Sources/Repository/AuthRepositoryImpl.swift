
import Foundation
import Domain
import DIContainer
import LivithNetwork

public struct AuthRepositoryImpl: AuthRepository {
    private let diContainer: DIContainer
    
    public func withdraw(reason: String) async throws(AuthError) {
        fatalError("Not implemented yet")
    }

    public func logout() async throws(AuthError) {
        fatalError("Not implemented yet")
    }

    public func checkNicknameDuplicate(nickname: String) async throws(AuthError) -> Bool {
        fatalError("Not implemented yet")
    }

    public func signup(tempUser: TempUser, marketingConsent: Bool, nickname: String) async throws(AuthError) {
        fatalError("Not implemented yet")
    }

    public func kakaoLogin() async throws(AuthError) -> LoginStatus {
        fatalError("Not implemented yet")
    }

    public func appleLogin() async throws(AuthError) -> LoginStatus {
        fatalError("Not implemented yet")
    }

    public func fetchLastLoginPlatform() async throws(AuthError) -> SocialLoginProvider {
        fatalError("Not implemented yet")
    }
}
