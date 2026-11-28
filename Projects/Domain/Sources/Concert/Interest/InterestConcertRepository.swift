public protocol InterestConcertRepository {
    func fetchInterestedConcertList(filter: InterestConcertListFilter) async throws(UserError) -> ListResult<InterestConcert>
    func checkInterestedConcert(id: Int) async throws(UserError) -> Bool
    @discardableResult
    func updateInterestedConcert(_ concertID: Int) async throws(UserError) -> Concert
    @discardableResult
    func updateInterestedConcertList(_ concertIDList: [Int]) async throws(UserError) -> [Concert]
    func deleteInterestedConcert() async throws(UserError)
}
