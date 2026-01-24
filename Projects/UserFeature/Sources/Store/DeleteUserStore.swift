//
//  DeleteUserStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 12/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
import LivithNetwork

enum DeleteUserReason: String, CaseIterable {
    case lackOfInfo = "원하는 정보가 부족하거나 없어요"
    case rarelyUsed = "서비스를 자주 이용하지 않아요"
    case inconvenient = "서비스 오류로 이용이 불편해요"
    case other = "기타"
}

enum DeleteUserResult: Equatable {
    case idle
    case success
    case failure(String)
}

struct DeleteUserState {
    var selectedReasons: Set<DeleteUserReason> = []
    var otherReasonText: String = ""
    var isLoading: Bool = false
    var deleteUserResult: DeleteUserResult = .idle
}

enum DeleteUserIntent {
    case toggleReason(DeleteUserReason)
    case updateOtherReasonText(String)
    case deleteUser
    case _setDeleteUserResult(DeleteUserResult)
}

final class DeleteUserStore: ObservableObject {
    @Published private(set) var state = DeleteUserState()
    @Injected private var authRepository: AuthRepository

    private let maxOtherReasonLength = 200

    func send(_ intent: DeleteUserIntent) {
        switch intent {
        case .toggleReason(let reason):
            if state.selectedReasons.contains(reason) {
                state.selectedReasons.remove(reason)
            } else {
                state.selectedReasons.insert(reason)
            }

        case .updateOtherReasonText(let text):
            if text.count <= maxOtherReasonLength {
                state.otherReasonText = text
            }

        case .deleteUser:
            state.deleteUserResult = .idle
            performDeleteUser()

        case ._setDeleteUserResult(let result):
            state.isLoading = false
            state.deleteUserResult = result
        }
    }

    var isConfirmButtonEnabled: Bool {
        guard !state.selectedReasons.isEmpty else { return false }

        if state.selectedReasons.contains(.other) {
            return state.otherReasonText.count >= 10
        }

        return true
    }

    var otherReasonTextCount: Int {
        state.otherReasonText.count
    }
}

// MARK: - Helper

private extension DeleteUserStore {
    func performDeleteUser() {
        state.isLoading = true

        Task {
            do {
                let reason = buildReasonString()
                try await authRepository.withdraw(reason: reason)

                await MainActor.run {
                    send(._setDeleteUserResult(.success))
                }
            } catch {
                await MainActor.run {
                    send(._setDeleteUserResult(.failure(error.localizedDescription)))
                }
            }
        }
    }

    func buildReasonString() -> String {
        var reasons = state.selectedReasons
            .filter { $0 != .other }
            .map { $0.rawValue }

        if state.selectedReasons.contains(.other), !state.otherReasonText.isEmpty {
            reasons.append(state.otherReasonText)
        }

        return reasons.joined(separator: ", ")
    }
}
