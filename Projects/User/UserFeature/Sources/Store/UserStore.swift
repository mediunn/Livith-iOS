//
//  UserStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/2/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Persistence

struct UserState {
    var nickname: String = ""
}

enum UserIntent {
    case fetchNickname
}

final class UserStore: ObservableObject {
    @Published private(set) var state = UserState()

    private let localStorage: LocalKeyValueStorage

    init(localStorage: LocalKeyValueStorage = UserDefaultsStorage()) {
        self.localStorage = localStorage
    }

    @MainActor
    func send(_ intent: UserIntent) {
        switch intent {
        case .fetchNickname:
            fetchNicknameFromStorage()
        }
    }
}

// MARK: - Helper

private extension UserStore {
    @MainActor
    func fetchNicknameFromStorage() {
        guard let user: StoredUserInfo = try? localStorage.fetch(for: "currentUser") else {
            return
        }
        state.nickname = user.nickname
    }
}

// MARK: - StoredUserInfo

private struct StoredUserInfo: Decodable {
    let nickname: String
}
