public protocol ConcertRecommendationRepository {
    func fetchRecommendedConcertList() async throws(ConcertError) -> [Concert]
}
