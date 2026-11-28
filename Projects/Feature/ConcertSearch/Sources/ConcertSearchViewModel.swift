import Observation

import Domain

@MainActor
@Observable
public final class ConcertSearchViewModel {
    public struct Criteria {
        let keyword: String
        let genreList: [ConcertGenre]
        let statusList: [ConcertStatus]
        let sort: SearchSort?

        public init(
            keyword: String,
            genreList: [ConcertGenre] = [],
            statusList: [ConcertStatus],
            sort: SearchSort? = nil
        ) {
            self.keyword = keyword
            self.genreList = genreList
            self.statusList = statusList
            self.sort = sort
        }
    }

    public enum FailurePolicy {
        case keepResults
        case clearResults
    }

    private enum LoadingPhase {
        case idle
        case firstPage
        case nextPage
    }

    public private(set) var concertList: [Concert]?
    public var hasNextPage: Bool { nextCursor != nil }
    public var isLoadingFirstPage: Bool { loadingPhase == .firstPage }
    public var isLoadingNextPage: Bool { loadingPhase == .nextPage }

    private let repository: any SearchRepository
    private let failurePolicy: FailurePolicy
    private var nextCursor: (any PagePosition)?
    private var loadingPhase = LoadingPhase.idle
    @ObservationIgnored private var criteria: Criteria?
    @ObservationIgnored private var request: Task<Void, Never>?

    public init(repository: any SearchRepository, failurePolicy: FailurePolicy) {
        self.repository = repository
        self.failurePolicy = failurePolicy
    }

    public func search(_ criteria: Criteria) async -> Result<[Concert], SearchError>? {
        guard !Task.isCancelled else { return nil }
        invalidateSearch()
        self.criteria = criteria
        return await fetchPage(for: criteria, after: nil, delay: .zero)
    }

    public func loadNextPage(delay: Duration = .zero) async -> Result<[Concert], SearchError>? {
        guard !Task.isCancelled, loadingPhase == .idle, let criteria, let nextCursor else { return nil }
        return await fetchPage(for: criteria, after: nextCursor, delay: delay)
    }

    public func invalidateSearch() {
        request?.cancel()
        request = nil
        nextCursor = nil
        loadingPhase = .idle
    }

    public func reset() {
        invalidateSearch()
        criteria = nil
        concertList = nil
    }
}

private extension ConcertSearchViewModel {
    func fetchPage(
        for criteria: Criteria,
        after cursor: (any PagePosition)?,
        delay: Duration
    ) async -> Result<[Concert], SearchError>? {
        let repository = repository
        loadingPhase = cursor == nil ? .firstPage : .nextPage

        var result: Result<ListResult<Concert>, SearchError>?
        let task = Task {
            if delay > .zero {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }

            do throws(SearchError) {
                result = .success(try await repository.fetchFilterSearchResult(
                    genre: criteria.genreList,
                    sort: criteria.sort,
                    status: criteria.statusList,
                    keyword: criteria.keyword,
                    after: cursor,
                    size: 12
                ))
            } catch where error == .cancelled {
                return
            } catch {
                result = .failure(error)
            }
        }

        request = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }

        guard request == task else { return nil }
        request = nil
        loadingPhase = .idle

        guard !Task.isCancelled, let result else { return nil }
        apply(result, isNextPage: cursor != nil)
        return result.map(\.items)
    }

    func apply(_ result: Result<ListResult<Concert>, SearchError>, isNextPage: Bool) {
        switch result {
        case .success(let page):
            if isNextPage {
                concertList?.append(contentsOf: page.items)
            } else {
                concertList = page.items
            }
            nextCursor = page.position
        case .failure:
            if failurePolicy == .clearResults {
                concertList = []
                nextCursor = nil
            }
        }
    }
}
