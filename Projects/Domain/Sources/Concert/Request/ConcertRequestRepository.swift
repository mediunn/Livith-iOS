public protocol ConcertRequestRepository {
    func requestConcert(
        title: String,
        url: String?,
        shouldAutoRegister: Bool,
        requestContent: String?
    ) async throws(ConcertError)
}
