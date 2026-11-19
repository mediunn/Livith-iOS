public protocol ConcertRequestRepository: Sendable {
    func requestConcert(_ request: ConcertRequest) async throws(ConcertError)
}
