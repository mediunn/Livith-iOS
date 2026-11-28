//
//  UserStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/2/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

struct UserState {
    var genres: [PreferredGenre] = []
    var artists: [PreferredArtist] = []

    var hasGenreData: Bool { !genres.isEmpty }
    var hasArtistData: Bool { !artists.isEmpty }
}

enum UserIntent {
    case fetchPreferences
    case _fetchGenreListResult(Result<[PreferredGenre], Error>)
    case _fetchArtistListResult(Result<[PreferredArtist], Error>)
}

final class UserStore: ObservableObject {
    @Published private(set) var state = UserState()

    @Injected private var preferenceRepository: PreferenceRepository

    @MainActor
    func send(_ intent: UserIntent) {
        switch intent {
        case .fetchPreferences:
            performFetchGenreList()
            performFetchArtistList()

        case ._fetchGenreListResult(let result):
            switch result {
            case .success(let genres):
                state.genres = genres
            case .failure:
                break
            }

        case ._fetchArtistListResult(let result):
            switch result {
            case .success(let artists):
                state.artists = artists
            case .failure:
                break
            }
        }
    }
}

// MARK: - Helper

private extension UserStore {
    func performFetchGenreList() {
        Task {
            do {
                let genres = try await preferenceRepository.fetchUserPreferredGenreList()
                await send(._fetchGenreListResult(.success(genres)))
            } catch {
                await send(._fetchGenreListResult(.failure(error)))
            }
        }
    }

    func performFetchArtistList() {
        Task {
            do {
                let artists = try await preferenceRepository.fetchUserPreferredArtistList()
                await send(._fetchArtistListResult(.success(artists)))
            } catch {
                await send(._fetchArtistListResult(.failure(error)))
            }
        }
    }
}
