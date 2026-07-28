//
//  UserGenreUpdateStore.swift
//  UserFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import DIContainer

enum UserGenreUpdateIntent {
    case onSubmit([PreferredGenre])
    case _updateGenreResult(Result<Void, Error>)
}

struct UserGenreUpdateState {
    enum UpdateResult {
        case idle, success, failure
    }
    
    var result: UpdateResult = .idle
    var isLoading: Bool = false
}

@MainActor
final class UserGenreUpdateStore: ObservableObject {
    @Published private(set) var state: UserGenreUpdateState = .init()
    
    @Injected private var preferenceRepository: PreferenceRepository
    @Injected private var userRepository: UserRepository

    func send(_ intent: UserGenreUpdateIntent) {
        switch intent {
        case .onSubmit(let genreList):
            state.isLoading = true
            performUpdateUserGenres(genreList)
        case ._updateGenreResult(let result):
            switch result {
            case .success:
                state.result = .success
            case .failure:
                state.result = .failure
            }
            state.isLoading = false
        }
    }    
}

private extension UserGenreUpdateStore {
    func performUpdateUserGenres(_ genreList: [PreferredGenre]) {
        guard !genreList.isEmpty else { return }
        
        Task {
            do {
                try await preferenceRepository.updateUserPreferredGenreList(genreIDs: genreList.map { $0.id })
                _ = try? await userRepository.refreshUser()
                state.result = .success
            } catch {
                state.result = .failure
            }
            state.isLoading = false
        }
    }
}
