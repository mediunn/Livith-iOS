//
//  DeleteUserStore.swift
//  UserFeature
//
//  Created by Youjin Lee on 12/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import UserDomain

enum WithdrawalReason: String, CaseIterable {
    case lackOfInfo = "원하는 정보가 부족하거나 없어요"
    case rarelyUsed = "서비스를 자주 이용하지 않아요"
    case inconvenient = "서비스 오류로 이용이 불편해요"
    case other = "기타"
}

struct WithdrawalState {
    var selectedReasons: Set<WithdrawalReason> = []
    var otherReasonText: String = ""
    var isLoading: Bool = false
    var isSucceed: Bool = false
    var errorMessage: String? = nil
}

enum WithdrawalIntent {
    case toggleReason(WithdrawalReason)
    case updateOtherReasonText(String)
    case withdraw
    case _setLoading(Bool)
    case _setResult(Result<Void, Error>)
}

final class DeleteUserStore: ObservableObject {
    @Published private(set) var state = WithdrawalState()

    private let maxOtherReasonLength = 200

    func send(_ intent: WithdrawalIntent) {
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

        case .withdraw:
            withdraw()

        case ._setLoading(let isLoading):
            state.isLoading = isLoading

        case ._setResult(let result):
            state.isLoading = false
            switch result {
            case .success:
                state.isSucceed = true
            case .failure(let error):
                state.errorMessage = error.localizedDescription
            }
        }
    }

    var isWithdrawButtonEnabled: Bool {
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
    func withdraw() {
        state.isLoading = true

        Task {
            // TODO: 실제 탈퇴 API 호출
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run {
                send(._setResult(.success(())))
            }
        }
    }
}
