import Foundation

public protocol ConcertCatalogRepository {
    func fetchAllConcertList(startDate: Date?, concertID: Int?) async throws(ConcertError) -> [Concert]
    func fetchAllConcertList(after nextToken: (any NextToken)?, size: Int) async throws(ConcertError) -> ListResult<Concert>
    func fetchSearchConcertSectionList() async throws(ConcertError) -> [ConcertSection]
}
