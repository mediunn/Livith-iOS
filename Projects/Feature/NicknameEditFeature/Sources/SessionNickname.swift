import Observation

@MainActor
@Observable
public final class SessionNickname {
    public var nickname: String?

    public init(nickname: String? = nil) {
        self.nickname = nickname
    }
}
