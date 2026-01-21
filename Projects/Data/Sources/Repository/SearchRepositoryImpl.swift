
import Foundation
import Domain
import DIContainer
import LivithNetwork

public struct SearchRepositoryImpl: SearchRepository {
    private let diContainer: DIContainer
    
    public func fetchBanners() async throws(SearchError) -> [Banner] {
        fatalError("Not implemented yet")
    }

    public func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        cursor: String?,
        size: Int?
    ) async throws(SearchError) -> SearchResultEntity {
        fatalError("Not implemented yet")
    }

    public func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] {
        fatalError("Not implemented yet")
    }

    public func fetchRecommendKeywordList(for keyword: String) async throws(SearchError) -> [String] {
        fatalError("Not implemented yet")
    }
}
