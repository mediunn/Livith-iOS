//
//  GenreSelectionStore.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DisplaySupport
import Domain
import DIContainer

enum GenreSelectionIntent {
    case onAppear
    case toggle(id: Int)
    case resetMaxSelectionToast
    case resetErrorToast
    case _fetchGenreListResult(Result<[PreferredGenre], Error>)
}

public struct GenreSelectionState: Equatable {
    var selection: PreferenceSelection<PreferredGenre>
    public var selectedGenreList: [PreferredGenre] { selection.items }
    var isLoading: Bool = false
    var genreList: [PreferredGenre] = []
    var isMaxSelectionToastPresented: Bool = false
    var isErrorToastPresented: Bool = false
    var errorMessage: String = ""
    
    init(selectedGenreList: [PreferredGenre] = []) {
        self.selection = PreferenceSelection(selectedGenreList)
    }
    
    var isModified: Bool { selection.hasChangesToSave }
}

public final class GenreSelectionStore: ObservableObject {    
    @Published public private(set) var state: GenreSelectionState
    
    @Injected private var preferenceRepository: PreferenceRepository
    
    public init(selectedGenreList: [PreferredGenre] = []) {
        self.state = GenreSelectionState(selectedGenreList: selectedGenreList)
    }
    
    @MainActor
    func send(_ intent: GenreSelectionIntent) {
        switch intent {
        case .onAppear:
            state.isLoading = true
            fetchGenreList()
            
        case .toggle(let id):
            guard let item = state.genreList.first(where: { $0.id == id }) else { return }
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
            
        case ._fetchGenreListResult(let result):
            state.isLoading = false
            switch result {
            case .success(let genres):
                state.genreList = genres
            case .failure(let error):
                state.errorMessage = DisplayErrorMessage.message(for: error)
                state.isErrorToastPresented = true
            }
        }
    }
}

// MARK: - Helpers

private extension GenreSelectionStore {
    func fetchGenreList() {
        Task {
            do {
                let genres = try await preferenceRepository.fetchGenreList()
                await send(._fetchGenreListResult(.success(genres)))
            } catch {
                await send(._fetchGenreListResult(.failure(error)))
            }
        }
    }
}
