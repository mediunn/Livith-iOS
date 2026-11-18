public protocol InterestConcertEntryAlertRepository {
    func fetchInterestConcertEntryAlerts() async throws(UserError) -> [InterestConcertEntryAlert]
}
