//
//  NicknameEditStore.swift
//  NicknameEditFeature
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain

// MARK: - State

public struct NicknameEditState: Equatable {
    public var nickname: String = ""
    public var validationState: NicknameValidationState = .idle
    public var isSubmitting: Bool = false
    public var submitResult: NicknameSubmitResult = .idle

    public init() {}
}

public enum NicknameSubmitResult: Equatable {
    case idle
    case success
    case failure(String)
}

// MARK: - Store

@MainActor
public final class NicknameEditStore: ObservableObject {
    @Published public private(set) var state = NicknameEditState()

    @Injected private var authRepository: AuthRepository
    @Injected private var userRepository: UserRepository

    private let config: NicknameEditConfig

    public init(config: NicknameEditConfig) {
        self.config = config
    }

    // MARK: - Public Interface

    public var nickname: String { state.nickname }
    public var validationState: NicknameValidationState { state.validationState }
    public var isSubmitting: Bool { state.isSubmitting }

    public func updateNickname(_ nickname: String) {
        state.nickname = nickname
        state.submitResult = .idle
        validateNicknameFormat()
    }

    public func checkDuplicate() {
        state.validationState = .checking
        performDuplicateCheck()
    }

    public func submit() {
        state.isSubmitting = true
        state.submitResult = .idle
        performSubmit()
    }

    public func resetSubmitResult() {
        state.submitResult = .idle
    }
}

// MARK: - Private

private extension NicknameEditStore {
    func validateNicknameFormat() {
        guard !state.nickname.isEmpty else {
            state.validationState = .idle
            return
        }
        
        do {
            _ = try Nickname(state.nickname)
            state.validationState = .valid
        } catch {
            state.validationState = .invalid
        }
    }

    func performDuplicateCheck() {
        Task {
            do {
                let isAvailable = try await authRepository.checkNicknameDuplicate(nickname: state.nickname)
                state.validationState = isAvailable ? .available : .duplicate
            } catch {
                state.validationState = .duplicate
            }
        }
    }

    func performSubmit() {
        Task {
            do {
                switch config {
                case .signup:
                    break // 회원가입 API는 PreferredArtistSettingView에서 호출
                case .update:
                    try await userRepository.updateNickname(state.nickname)
                }
                state.isSubmitting = false
                state.submitResult = .success
            } catch {
                state.isSubmitting = false
                state.submitResult = .failure(error.localizedDescription)
            }
        }
    }
}
