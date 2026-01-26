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
}

enum UserIntent {
    case fetchNickname
    case _fetchUserResult(Result<User, Error>)
}

final class UserStore: ObservableObject {
    @Published private(set) var state = UserState()

    @Injected private var userRepository: UserRepository

    @MainActor
    func send(_ intent: UserIntent) {
        switch intent {
        case .fetchNickname:
            performFetchUser()
            
        case ._fetchUserResult(let result):
            switch result {
            case .success(let user):
                state.nickname = user.nickname
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
}
