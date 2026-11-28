import Foundation

import Domain
import Testing

@testable import SearchFeature

@Suite("일반 공연 검색")
@MainActor
struct ExploreSearchViewModelTests {
    @Test("디바운스 기간에는 요청하지 않고 입력을 확정한 뒤 조회한다")
    func searchesAfterDebounce() async throws {
        let repository = SearchRepositoryStub()
        let viewModel = ExploreSearchViewModel(repository: repository)

        viewModel.updateSearchText("공연")
        viewModel.submitSearch()
        #expect(repository.keywordList.isEmpty)
        try await waitUntil { !viewModel.concertList.isEmpty }

        #expect(repository.keywordList == ["공연"])
        #expect(viewModel.concertList.map(\.id) == [1])
    }

    @Test("미확정 텍스트가 있어도 기존 검색어로 다음 페이지를 조회한다")
    func paginationUsesSubmittedKeyword() async throws {
        let repository = SearchRepositoryStub()
        let viewModel = ExploreSearchViewModel(repository: repository)
        viewModel.updateSearchText("이전 검색")
        viewModel.loadIfNeeded()
        try await waitUntil { !viewModel.concertList.isEmpty }

        viewModel.updateSearchText("새 입력")
        await viewModel.loadNextPage()
        await viewModel.loadNextPage()

        #expect(repository.keywordList == ["이전 검색", "이전 검색"])
        #expect(viewModel.concertList.map(\.id) == [1, 2])
    }

    @Test("다음 페이지 실패 후 검색 결과와 기존 커서를 유지한다")
    func retriesFailedPage() async throws {
        let repository = SearchRepositoryStub()
        let viewModel = ExploreSearchViewModel(repository: repository)
        viewModel.loadIfNeeded()
        try await waitUntil { !viewModel.concertList.isEmpty }

        repository.nextPageError = .unknown
        await viewModel.loadNextPage()

        #expect(viewModel.errorMessage == "알 수 없는 오류가 발생했습니다.")
        #expect(viewModel.concertList.map(\.id) == [1])
        #expect(!viewModel.isLoadingMore)

        repository.nextPageError = nil
        await viewModel.loadNextPage()
        #expect(viewModel.concertList.map(\.id) == [1, 2])
    }

    @Test("검색어를 지우면 현재 필터와 정렬을 사용해 다시 조회한다")
    func clearingReusesFiltersAndSort() async throws {
        let repository = SearchRepositoryStub()
        let viewModel = ExploreSearchViewModel(repository: repository)
        viewModel.updateSearchText("공연")
        viewModel.applyFilters(genreList: [], statusList: [.upcoming])
        try await waitUntil { repository.keywordList.count == 1 }
        viewModel.changeSort(to: .alphabetical)
        try await waitUntil { repository.keywordList.count == 2 }

        viewModel.updateSearchText("")
        try await waitUntil { repository.keywordList.count == 3 }

        #expect(repository.keywordList == ["공연", "공연", ""])
        #expect(repository.lastStatusList == [.upcoming])
        #expect(repository.lastSort == .alphabetical)
    }

    private func waitUntil(_ condition: @MainActor () -> Bool) async throws {
        let deadline = ContinuousClock.now + .seconds(2)
        while !condition(), ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }
        try #require(condition())
    }
}

@MainActor
private final class SearchRepositoryStub: SearchRepository {
    private(set) var keywordList: [String] = []
    private(set) var lastStatusList: [ConcertStatus] = []
    private(set) var lastSort: SearchSort?
    var nextPageError: SearchError?

    func fetchBanners() async throws(SearchError) -> [Banner] { [] }

    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        after position: (any PagePosition)?,
        size: Int?
    ) async throws(SearchError) -> ListResult<Concert> {
        keywordList.append(keyword ?? "")
        lastStatusList = status
        lastSort = sort
        if position != nil, let nextPageError { throw nextPageError }
        return ListResult(
            items: [makeConcert(id: position == nil ? 1 : 2)],
            position: position == nil ? TestSearchPosition() : nil
        )
    }

    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] { [] }
}

private extension SearchRepositoryStub {
    func makeConcert(id: Int) -> Concert {
        Concert(
            id: id,
            title: "공연 \(id)",
            artist: "아티스트",
            status: .upcoming,
            daysLeft: 10,
            startDate: Date(timeIntervalSince1970: 1_783_584_000),
            endDate: Date(timeIntervalSince1970: 1_783_670_400),
            posterURL: nil,
            venue: "공연장",
            ticketSite: "예매처",
            ticketURL: nil,
            introduction: "",
            label: nil
        )
    }
}

private struct TestSearchPosition: PagePosition {}
