public protocol ConcertRequestRepository {
    func requestConcert(_ request: ConcertRequest) async throws(ConcertError)
}
