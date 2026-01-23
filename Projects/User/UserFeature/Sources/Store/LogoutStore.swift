//
//  LogoutStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetwork

enum LogoutResult: Equatable {
    case idle
    case success
    case failure(String)
}

struct LogoutState {
    var isLoading: Bool = false
    var logoutResult: LogoutResult = .idle
}

enum LogoutIntent {
    case logout
    case _setLogoutResult(LogoutResult)
}

final class LogoutStore: ObservableObject {
    @Published private(set) var state = LogoutState()
    @Injected private var authRepository: AuthRepository

    func send(_ intent: LogoutIntent) {
        switch intent {
        case .logout:
            state.logoutResult = .idle
            performLogout()

        case ._setLogoutResult(let result):
            state.isLoading = false
            state.logoutResult = result
        }
    }
}

// MARK: - Helper

private extension LogoutStore {
    func performLogout() {
        state.isLoading = true

        Task {
            do {
                try await authRepository.logout()

                await MainActor.run {
                    send(._setLogoutResult(.success))
                }
            } catch {
                await MainActor.run {
                    send(._setLogoutResult(.failure(error.localizedDescription)))
                }
            }
        }
    }
}
