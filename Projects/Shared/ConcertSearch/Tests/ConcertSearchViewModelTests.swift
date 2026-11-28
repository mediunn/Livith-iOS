import Domain
import Testing

import ConcertSearch

@Suite("공통 공연 검색 상태")
@MainActor
struct ConcertSearchViewModelTests {
    @Test("초기화한 검색의 늦은 응답은 결과나 오류에 반영하지 않는다", arguments: [true, false])
    func ignoresResponseAfterReset(succeeds: Bool) async throws {
        let repository = SearchRepositoryStub()
        let search = ConcertSearchViewModel(repository: repository, failurePolicy: .clearResults)
        let task = Task {
            await search.search(.init(keyword: "이전", statusList: [])) { _ in
                Issue.record("초기화한 요청의 결과가 전달됨")
            }
        }
        try await repository.waitForRequest()

        search.reset()
        repository.finish(succeeds ? .success(.init(items: [], position: Cursor())) : .failure(.unknown))
        await task.value

        #expect(search.concertList == nil)
        #expect(!search.hasNextPage)
        #expect(!search.isLoadingFirstPage)
    }

    @Test("같은 검색어로 다시 조회해도 이전 요청을 무시하고 화면별 상태를 보존한다")
    func ignoresReplacedRequestWithSameKeyword() async throws {
        let repository = SearchRepositoryStub()
        let search = ConcertSearchViewModel(repository: repository, failurePolicy: .clearResults)
        let otherSearch = ConcertSearchViewModel(repository: repository, failurePolicy: .clearResults)
        let criteria = ConcertSearchViewModel.Criteria(keyword: "공연", statusList: [])
        let old = Task {
            await search.search(criteria) { _ in Issue.record("교체된 요청의 결과가 전달됨") }
        }
        try await repository.waitForRequest()
        let current = Task { await search.search(criteria) { _ in } }
        try await repository.waitForRequest(count: 2)
        let independent = Task { await otherSearch.search(criteria) { _ in } }
        try await repository.waitForRequest(count: 3)

        repository.finish(.failure(.unknown))
        await old.value

        #expect(search.isLoadingFirstPage)
        #expect(otherSearch.isLoadingFirstPage)

        repository.finish(.success(.init(items: [], position: Cursor())))
        await current.value
        #expect(search.hasNextPage)
        #expect(!search.isLoadingFirstPage)
        #expect(otherSearch.isLoadingFirstPage)

        repository.finish(.success(.init(items: [], position: nil)))
        await independent.value
        #expect(search.hasNextPage)
        #expect(!otherSearch.hasNextPage)
    }

    @Test("추가 페이지는 첫 조회 조건을 사용하고 중복 호출을 무시한다")
    func preventsDuplicatePagination() async throws {
        let repository = SearchRepositoryStub()
        let search = ConcertSearchViewModel(repository: repository, failurePolicy: .keepResults)
        let first = Task { await search.search(.init(keyword: "공연", statusList: [.upcoming])) { _ in } }
        try await repository.waitForRequest()
        repository.finish(.success(.init(items: [], position: Cursor())))
        await first.value

        let next = Task { await search.loadNextPage { _ in } }
        try await repository.waitForRequest()
        #expect(search.isLoadingNextPage)
        await search.loadNextPage { _ in Issue.record("중복 요청의 결과가 전달됨") }
        repository.finish(.success(.init(items: [], position: nil)))
        await next.value

        #expect(repository.keywordList == ["공연", "공연"])
        #expect(repository.statusListsByRequest == [[.upcoming], [.upcoming]])
        #expect(repository.requestHasCursor == [false, true])
        #expect(!search.hasNextPage)
        #expect(!search.isLoadingNextPage)
    }
}

@MainActor
private final class SearchRepositoryStub: SearchRepository {
    private var pendingResponses: [CheckedContinuation<Result<ListResult<Concert>, SearchError>, Never>] = []
    private(set) var keywordList: [String?] = []
    private(set) var statusListsByRequest: [[ConcertStatus]] = []
    private(set) var requestHasCursor: [Bool] = []

    func fetchBanners() async throws(SearchError) -> [Banner] { [] }

    func fetchFilterSearchResult(
        genre: [ConcertGenre],
        sort: SearchSort?,
        status: [ConcertStatus],
        keyword: String?,
        after position: (any PagePosition)?,
        size: Int?
    ) async throws(SearchError) -> ListResult<Concert> {
        keywordList.append(keyword)
        statusListsByRequest.append(status)
        requestHasCursor.append(position != nil)
        let result = await withCheckedContinuation { pendingResponses.append($0) }
        return try result.get()
    }

    func fetchRecommendedSearchResult(keyword: String) async throws(SearchError) -> [String] { [] }

    func waitForRequest(count: Int = 1) async throws {
        let deadline = ContinuousClock.now + .seconds(2)
        while pendingResponses.count < count, ContinuousClock.now < deadline {
            try await Task.sleep(for: .milliseconds(5))
        }
        try #require(pendingResponses.count == count)
    }

    func finish(_ result: Result<ListResult<Concert>, SearchError>) {
        pendingResponses.removeFirst().resume(returning: result)
    }
}

private struct Cursor: PagePosition {}
