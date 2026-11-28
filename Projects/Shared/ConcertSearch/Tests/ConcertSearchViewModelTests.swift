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
            let result = await search.search(.init(keyword: "이전", statusList: []))
            #expect(result == nil)
        }
        try await repository.waitForRequest()

        search.reset()
        repository.finish(succeeds ? .success(.init(items: [], position: Cursor())) : .failure(.unknown))
        await task.value

        #expect(search.concertList == nil)
        #expect(!search.hasNextPage)
        #expect(!search.isLoadingFirstPage)
    }

    @Test("호출자가 취소하거나 Repository가 취소를 반환하면 결과가 없다", arguments: [true, false])
    func returnsNilOnCancellation(cancelCaller: Bool) async throws {
        let repository = SearchRepositoryStub()
        let search = ConcertSearchViewModel(repository: repository, failurePolicy: .clearResults)
        let task = Task {
            let result = await search.search(.init(keyword: "공연", statusList: []))
            #expect(result == nil)
        }
        try await repository.waitForRequest()

        if cancelCaller { task.cancel() }
        repository.finish(cancelCaller ? .success(.init(items: [], position: Cursor())) : .failure(.cancelled))
        await task.value

        #expect(search.concertList == nil)
        #expect(!search.isLoadingFirstPage)
    }

    @Test("같은 검색어로 다시 조회해도 이전 요청을 무시하고 화면별 상태를 보존한다")
    func ignoresReplacedRequestWithSameKeyword() async throws {
        let repository = SearchRepositoryStub()
        let search = ConcertSearchViewModel(repository: repository, failurePolicy: .clearResults)
        let otherSearch = ConcertSearchViewModel(repository: repository, failurePolicy: .clearResults)
        let criteria = ConcertSearchViewModel.Criteria(keyword: "공연", statusList: [])
        let old = Task {
            let result = await search.search(criteria)
            #expect(result == nil)
        }
        try await repository.waitForRequest()
        let current = Task { _ = await search.search(criteria) }
        try await repository.waitForRequest(count: 2)
        let independent = Task { _ = await otherSearch.search(criteria) }
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
        let first = Task { _ = await search.search(.init(keyword: "공연", statusList: [.upcoming])) }
        try await repository.waitForRequest()
        repository.finish(.success(.init(items: [], position: Cursor())))
        await first.value

        let next = Task {
            let result = await search.loadNextPage()
            #expect((try? result?.get()) == [])
        }
        try await repository.waitForRequest()
        #expect(search.isLoadingNextPage)
        repository.rejectsNewRequests = true
        let duplicate = await search.loadNextPage()
        #expect(duplicate == nil)
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
    var rejectsNewRequests = false
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
        guard !rejectsNewRequests else {
            Issue.record("진행 중인 페이지 요청 외에 추가 Repository 호출이 발생함")
            throw .unknown
        }
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
