
import Foundation
import Domain
import DIContainer
import LivithNetwork

public struct UserRepositoryImpl: UserRepository {
    private let diContainer: DIContainer
    
    public func updateNickname(_ nickname: String) async throws(UserError) {
        fatalError("Not implemented yet")
    }

    public func fetchUser() async throws(UserError) -> User {
        fatalError("Not implemented yet")
    }

    public func fetchInterestedConcert() async throws(UserError) -> Concert {
        fatalError("Not implemented yet")
    }

    @discardableResult
    public func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert {
        fatalError("Not implemented yet")
    }

    public func deleteInterestedConcert() async throws(UserError) {
        fatalError("Not implemented yet")
    }
}
