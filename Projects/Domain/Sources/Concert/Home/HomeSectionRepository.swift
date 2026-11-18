public protocol HomeSectionRepository {
    func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection]
    func fetchRecommendedConcertList() async throws(ConcertError) -> [Concert]
}
