//
//  UserArtistUpdateStore.swift
//  UserFeature
//
//  Created by 김진웅 on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import DIContainer

enum UserArtistUpdateIntent {
    case onSubmit([PreferredArtist])
    case _updateArtistResult(Result<Void, Error>)
}

struct UserArtistUpdateState {
    enum UpdateResult {
        case idle, success, failure
    }
    
    var result: UpdateResult = .idle
    var isLoading: Bool = false
}

@MainActor
final class UserArtistUpdateStore: ObservableObject {
    @Published private(set) var state: UserArtistUpdateState = .init()

    @Injected private var preferenceRepository: PreferenceRepository
    @Injected private var userRepository: UserRepository

    func send(_ intent: UserArtistUpdateIntent) {
        switch intent {
        case .onSubmit(let artistList):
            state.isLoading = true
            performUpdateUserArtists(artistList)
        case ._updateArtistResult(let result):
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

// MARK: - Helpers

private extension UserArtistUpdateStore {
    func performUpdateUserArtists(_ artistList: [PreferredArtist]) {
        guard !artistList.isEmpty else { return }
        
        Task {
            do {
                try await preferenceRepository.updateUserPreferredArtistList(artistIDs: artistList.map { $0.id })
                _ = try? await userRepository.refreshUser()
                state.result = .success
            } catch {
                state.result = .failure
            }
        }
    }
}