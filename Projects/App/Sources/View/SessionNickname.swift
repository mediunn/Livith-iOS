import Observation

@MainActor
@Observable
final class SessionNickname {
    private(set) var nickname: String?

    private let loadNickname: @MainActor () async throws -> String
    @ObservationIgnored private var isLoading = false
    @ObservationIgnored private var isActive = true

    init(nickname: String? = nil, loadNickname: @escaping @MainActor () async throws -> String) {
        self.nickname = nickname
        self.loadNickname = loadNickname
    }

    func loadIfNeeded() async {
        guard isActive, nickname == nil, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        guard let loadedNickname = try? await loadNickname(),
              isActive, nickname == nil, !Task.isCancelled
        else { return }
        nickname = loadedNickname
    }

    func applySavedNickname(_ nickname: String) {
        guard isActive else { return }
        self.nickname = nickname
    }

    func end() {
        isActive = false
        nickname = nil
    }
}
