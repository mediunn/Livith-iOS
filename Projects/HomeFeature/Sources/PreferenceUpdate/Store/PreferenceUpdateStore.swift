//
//  PreferenceUpdateStore.swift
//  HomeFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import DIContainer

enum PreferenceUpdateIntent {
    case onSkip
    case onSubmit([PreferredArtist])
}

struct PreferenceUpdateState {
    enum UpdateResult {
        case idle, success, failure
    }
    
    let selectedGenreList: [PreferredGenre]
    var isLoading: Bool = false
    var result: UpdateResult = .idle
    var errorMessage: String = ""
}

@MainActor
final class PreferenceUpdateStore: ObservableObject {
    @Published private(set) var state: PreferenceUpdateState
    
    @Injected private var repository: PreferenceRepository
    @Injected private var userRepository: UserRepository
    
    init(_ selectedGenreList: [PreferredGenre]) {
        self.state = .init(selectedGenreList: selectedGenreList)
    }
    
    func send(_ intent: PreferenceUpdateIntent) {
        switch intent {
        case .onSkip:
            state.isLoading = true
            state.result = .idle
            state.errorMessage = ""

            performSkip()
        case .onSubmit(let artistList):
            state.isLoading = true
            state.result = .idle
            state.errorMessage = ""

            performSubmit(artistList: artistList)
        }
    }
}

// MARK: - Helpers

private extension PreferenceUpdateStore {
    func performSkip() {
        Task {
            do {
                let genreIDList = state.selectedGenreList.map(\.id)
                _ = try await repository.updateUserPreferredGenreList(genreIDs: genreIDList)
                _ = try? await userRepository.refreshUser()
                state.result = .success
            } catch {
                state.result = .failure
                state.errorMessage = getErrorMessage(from: error)
            }
            state.isLoading = false
        }
    }
    
    func performSubmit(artistList: [PreferredArtist]) {
        Task {
            do {
                let genreIDList = state.selectedGenreList.map(\.id)
                let artistIDList = artistList.map(\.id)
                async let updateGenreList = repository.updateUserPreferredGenreList(genreIDs: genreIDList)
                async let updateArtistList = repository.updateUserPreferredArtistList(artistIDs: artistIDList)
                _ = try await (updateGenreList, updateArtistList)
                _ = try? await userRepository.refreshUser()
                
                state.result = .success
            } catch {
                state.result = .failure
                state.errorMessage = getErrorMessage(from: error)
            }
            state.isLoading = false
        }
    }
    
    func getErrorMessage(from error: Error) -> String {
        if error is CancellationError {
            return ""
        }
        return error.localizedDescription
    }
}
