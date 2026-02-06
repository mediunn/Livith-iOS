//
//  ArtistSelectionStore.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import DIContainer

enum ArtistSelectionIntent {
    case onAppear
    case search(keyword: String)
    case toggle(id: Int)
    case resetMaxSelectionToast
    case resetErrorToast
    case _searchResult(Result<[PreferredArtist], Error>)
    case loadMore
    case _searchMoreResult(Result<[PreferredArtist], Error>)
}

public struct ArtistSelectionState: Equatable {
    public var selectedArtistList: [PreferredArtist] = []
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var hasNextPage: Bool = true
    var artistList: [PreferredArtist] = []
    var searchKeyword: String = ""
    var isMaxSelectionToastPresented: Bool = false
    var isErrorToastPresented: Bool = false
    var errorMessage: String = ""
    
    private let initialSelectedArtistList: [PreferredArtist]
    
    init(selectedArtistList: [PreferredArtist] = []) {
        self.selectedArtistList = selectedArtistList
        self.initialSelectedArtistList = selectedArtistList
    }
    
    var isModified: Bool { selectedArtistList != initialSelectedArtistList }
}

public final class ArtistSelectionStore: ObservableObject {
    @Published public private(set) var state: ArtistSelectionState
    
    @Injected private var preferenceRepository: PreferenceRepository
    
    private var searchTask: Task<Void, Never>?
    
    public init(selectedArtistList: [PreferredArtist] = []) {
        self.state = ArtistSelectionState(selectedArtistList: selectedArtistList)
    }
    
    @MainActor
    func send(_ intent: ArtistSelectionIntent) {
        switch intent {
        case .onAppear:
            state.isLoading = true
            searchArtistList(keyword: nil)
            
        case .search(let keyword):
            state.searchKeyword = keyword
            
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                guard !Task.isCancelled else { return }
                
                if keyword.isEmpty {
                    searchArtistList(keyword: nil)
                } else {
                    searchArtistList(keyword: keyword)
                }
            }
            
        case .toggle(let id):
            if let index = state.selectedArtistList.firstIndex(where: { $0.id == id }) {
                state.selectedArtistList.remove(at: index)
                state.isMaxSelectionToastPresented = false
                return
            }
            
            if state.selectedArtistList.count < PreferenceSelectionRule.maxCount {
                guard let artist = state.artistList.first(where: { $0.id == id }) else { return }
                state.selectedArtistList.append(artist)
                state.isMaxSelectionToastPresented = false
            } else {
                state.isMaxSelectionToastPresented = true
            }
            
        case .resetMaxSelectionToast:
            state.isMaxSelectionToastPresented = false
            
        case .resetErrorToast:
            state.isErrorToastPresented = false
            
        case ._searchResult(let result):
            state.isLoading = false
            switch result {
            case .success(let artists):
                state.artistList = artists
                state.hasNextPage = true
            case .failure(let error):
                state.errorMessage = error.localizedDescription
                state.isErrorToastPresented = true
            }
            
        case .loadMore:
            guard !state.isLoading, !state.isLoadingMore, state.hasNextPage else { return }
            guard let lastID = state.artistList.last?.id else { return }
            
            state.isLoadingMore = true
            searchMoreArtistList(keyword: state.searchKeyword, cursor: String(lastID))
            
        case ._searchMoreResult(let result):
            state.isLoadingMore = false
            switch result {
            case .success(let artists):
                if artists.isEmpty {
                    state.hasNextPage = false
                } else {
                    state.artistList.append(contentsOf: artists)
                }
            case .failure(let error):
                state.errorMessage = error.localizedDescription
                state.isErrorToastPresented = true
            }
        }
    }
}

// MARK: - Helpers

private extension ArtistSelectionStore {
    func searchArtistList(keyword: String?) {
        Task {
            do {
                let result = try await preferenceRepository.searchArtistList(keyword: keyword, size: 12, cursor: nil)
                await send(._searchResult(.success(result.artists)))
            } catch {
                await send(._searchResult(.failure(error)))
            }
        }
    }
    
    func searchMoreArtistList(keyword: String, cursor: String) {
        Task {
            do {
                let searchKeyword = keyword.isEmpty ? nil : keyword
                let result = try await preferenceRepository.searchArtistList(keyword: searchKeyword, size: 12, cursor: cursor)
                await send(._searchMoreResult(.success(result.artists)))
            } catch {
                await send(._searchMoreResult(.failure(error)))
            }
        }
    }
}
