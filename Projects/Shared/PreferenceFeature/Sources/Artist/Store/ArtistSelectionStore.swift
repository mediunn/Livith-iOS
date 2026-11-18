//
//  ArtistSelectionStore.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DisplaySupport
import Domain
import DIContainer

enum ArtistSelectionIntent {
    case onAppear
    case search(keyword: String)
    case toggle(id: Int)
    case resetMaxSelectionToast
    case resetErrorToast
    case loadMore
    case _searchResult(Result<ListResult<PreferredArtist>, PreferenceError>, isNextPage: Bool)
}

public struct ArtistSelectionState: Equatable {
    var selection: PreferenceSelection<PreferredArtist>
    public var selectedArtistList: [PreferredArtist] { selection.items }
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var hasNextPage: Bool = false
    var artistList: [PreferredArtist] = []
    var searchKeyword: String = ""
    var isMaxSelectionToastPresented: Bool = false
    var isErrorToastPresented: Bool = false
    var errorMessage: String = ""
    
    init(selectedArtistList: [PreferredArtist] = []) {
        self.selection = PreferenceSelection(selectedArtistList)
    }
    
    var isModified: Bool { selection.hasChangesToSave }
}

public final class ArtistSelectionStore: ObservableObject {
    @Published public private(set) var state: ArtistSelectionState
    
    @Injected private var preferenceRepository: PreferenceRepository
    
    private var searchTask: Task<Void, Never>?
    private var position: (any PagePosition)?
    
    public init(selectedArtistList: [PreferredArtist] = []) {
        self.state = ArtistSelectionState(selectedArtistList: selectedArtistList)
    }
    
    @MainActor
    func send(_ intent: ArtistSelectionIntent) {
        switch intent {
        case .onAppear:
            state.isLoading = true
            let keyword = state.searchKeyword
            performSearch(keyword: keyword.isEmpty ? nil : keyword)

        case .search(let keyword):
            state.searchKeyword = keyword
            performSearch(keyword: keyword.isEmpty ? nil : keyword, delay: .milliseconds(300))

        case .toggle(let id):
            let item = state.artistList.first { $0.id == id }
            switch state.selection.toggle(id: id, availableItem: item) {
            case .changed:
                state.isMaxSelectionToastPresented = false
            case .limitReached:
                state.isMaxSelectionToastPresented = true
            case .itemUnavailable:
                break
            }

        case .resetMaxSelectionToast:
            state.isMaxSelectionToastPresented = false
            
        case .resetErrorToast:
            state.isErrorToastPresented = false
            
        case .loadMore:
            guard !state.isLoading, !state.isLoadingMore, let position else { return }

            state.isLoadingMore = true
            let keyword = state.searchKeyword
            performSearch(keyword: keyword.isEmpty ? nil : keyword, after: position)

        case ._searchResult(let result, let isNextPage):
            state.isLoading = false
            state.isLoadingMore = false

            switch result {
            case .success(let page):
                if isNextPage {
                    state.artistList.append(contentsOf: page.items)
                } else {
                    state.artistList = page.items
                }
                position = page.position
                state.hasNextPage = page.position != nil
            case .failure(let error):
                state.errorMessage = DisplayErrorMessage.message(for: error)
                state.isErrorToastPresented = true
            }
        }
    }
}

// MARK: - Helpers

private extension ArtistSelectionStore {
    @MainActor
    func performSearch(
        keyword: String?,
        after position: (any PagePosition)? = nil,
        delay: Duration? = nil
    ) {
        let isNextPage = position != nil
        searchTask?.cancel()
        if !isNextPage {
            self.position = nil
            state.hasNextPage = false
            state.isLoadingMore = false
        }

        searchTask = Task {
            if let delay {
                try? await Task.sleep(for: delay)
            }
            guard !Task.isCancelled else { return }

            do throws(PreferenceError) {
                let page = try await preferenceRepository.searchArtistList(keyword: keyword, size: 18, after: position)
                guard !Task.isCancelled else { return }
                send(._searchResult(.success(page), isNextPage: isNextPage))
            } catch {
                guard !Task.isCancelled else { return }
                send(._searchResult(.failure(error), isNextPage: isNextPage))
            }
        }
    }
}
