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
    var nickname: String = ""
    var genres: [PreferredGenre] = []
    var artists: [PreferredArtist] = []

    var hasGenreData: Bool { !genres.isEmpty }
    var hasArtistData: Bool { !artists.isEmpty }
}

enum UserIntent {
    case fetchUserInfo
    case _fetchUserResult(Result<User, Error>)
    case _fetchGenreListResult(Result<[PreferredGenre], Error>)
    case _fetchArtistListResult(Result<[PreferredArtist], Error>)
}

final class UserStore: ObservableObject {
    @Published private(set) var state = UserState()

    @Injected private var userRepository: UserRepository
    @Injected private var preferenceRepository: PreferenceRepository

    @MainActor
    func send(_ intent: UserIntent) {
        switch intent {
        case .fetchUserInfo:
            performFetchUser()
            performFetchGenreList()
            performFetchArtistList()

        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.nickname = user.nickname
            case .failure:
                break
            }

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
    func performFetchUser() {
        Task {
            do {
                let user = try await userRepository.fetchUser()
                await send(._fetchUserResult(.success(user)))
            } catch {
                await send(._fetchUserResult(.failure(error)))
            }
        }
    }

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
