import Observation

import ConcertSearch
import DisplaySupport
import Domain

@MainActor
@Observable
final class SearchViewModel {
    private(set) var searchText = ""
    private(set) var sort = SearchSort.latest
    private(set) var selectedGenreList: [ConcertGenre] = []
    private(set) var selectedStatusList: [ConcertStatus] = []
    private(set) var errorMessage = ""

    var concertList: [Concert] { concertSearch.concertList ?? [] }
    var isLoadingMore: Bool { concertSearch.isLoadingNextPage }

    private let concertSearch: ConcertSearchViewModel
    @ObservationIgnored private var didStartLoading = false
    @ObservationIgnored private var debounceTask: Task<Void, Never>?
    @ObservationIgnored private var firstPageTask: Task<Void, Never>?

    init(repository: any SearchRepository) {
        concertSearch = ConcertSearchViewModel(repository: repository, failurePolicy: .keepResults)
    }

    func loadIfNeeded() {
        guard !didStartLoading else { return }
        didStartLoading = true
        startSearch()
    }

    func updateSearchText(_ text: String) {
        let wasEmpty = searchText.isEmpty
        searchText = text
        if text.isEmpty && !wasEmpty {
            startSearch()
        }
    }

    func submitSearch() {
        guard !searchText.isEmpty else { return }
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            self?.startSearch()
        }
    }

    func changeSort(to sort: SearchSort) {
        self.sort = sort
        startSearch()
    }

    func applyFilters(genreList: [ConcertGenre], statusList: [ConcertStatus]) {
        selectedGenreList = genreList
        selectedStatusList = statusList
        startSearch()
    }

    func loadNextPage() async {
        if let result = await concertSearch.loadNextPage(delay: .milliseconds(500)) {
            showSearchError(result)
        }
    }
}

private extension SearchViewModel {
    func startSearch() {
        debounceTask?.cancel()
        firstPageTask?.cancel()
        concertSearch.invalidateSearch()
        let criteria = ConcertSearchViewModel.Criteria(
            keyword: searchText,
            genreList: selectedGenreList,
            statusList: selectedStatusList,
            sort: sort
        )
        firstPageTask = Task { [concertSearch, weak self] in
            if let result = await concertSearch.search(criteria) {
                self?.showSearchError(result)
            }
        }
    }

    func showSearchError(_ result: Result<[Concert], SearchError>) {
        if case .failure(let error) = result {
            errorMessage = DisplayErrorMessage.message(for: error)
        }
    }
}
