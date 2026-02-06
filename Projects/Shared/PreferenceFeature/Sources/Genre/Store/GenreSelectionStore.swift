//
//  GenreSelectionStore.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/30/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

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
    public var selectedGenreList: [PreferredGenre] = []
    var isLoading: Bool = false
    var genreList: [PreferredGenre] = []
    var isMaxSelectionToastPresented: Bool = false
    var isErrorToastPresented: Bool = false
    var errorMessage: String = ""
    
    private let initialSelectedGenreList: [PreferredGenre]
    
    init(selectedGenreList: [PreferredGenre] = []) {
        self.selectedGenreList = selectedGenreList
        self.initialSelectedGenreList = selectedGenreList
    }
    
    var isModified: Bool { selectedGenreList != initialSelectedGenreList }
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
            guard let genre = state.genreList.first(where: { $0.id == id }) else { return }
            
            if let index = state.selectedGenreList.firstIndex(where: { $0.id == id }) {
                state.selectedGenreList.remove(at: index)
                state.isMaxSelectionToastPresented = false
            } else if state.selectedGenreList.count < PreferenceSelectionRule.maxCount {
                state.selectedGenreList.append(genre)
                state.isMaxSelectionToastPresented = false
            } else {
                state.isMaxSelectionToastPresented = true
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
                state.errorMessage = error.localizedDescription
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
