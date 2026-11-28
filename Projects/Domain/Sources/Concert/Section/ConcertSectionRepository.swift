public protocol ConcertSectionRepository {
    func fetchHomeConcertSectionList() async throws(ConcertError) -> [ConcertSection]
}
