//
//  NicknameEditStore.swift
//  NicknameEditFeature
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import DIContainer
import DisplaySupport
import Domain

// MARK: - State

public struct NicknameEditState: Equatable {
    public var nickname: String = ""
    public var validationState: NicknameValidationState = .idle
    public var isSubmitting: Bool = false
    public var submitResult: NicknameSubmitResult = .idle
    var submittedNickname: Nickname?

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
    private var nicknameCheckID: UUID?

    public init(config: NicknameEditConfig) {
        self.config = config
    }

    // MARK: - Public Interface

    public var nickname: String { state.nickname }
    public var validationState: NicknameValidationState { state.validationState }
    public var isSubmitting: Bool { state.isSubmitting }

    public func updateNickname(_ nickname: String) {
        nicknameCheckID = nil
        state.nickname = nickname
        state.submitResult = .idle
        validateNicknameFormat()
    }

    public func checkDuplicate() {
        guard let nickname = try? Nickname(state.nickname) else { return }
        let checkID = UUID()
        nicknameCheckID = checkID
        state.validationState = .checking
        performDuplicateCheck(for: nickname, checkID: checkID)
    }

    public func submit() {
        guard !state.isSubmitting, let nickname = try? Nickname(state.nickname) else { return }
        if case .signup = config, state.validationState != .available { return }
        state.isSubmitting = true
        state.submitResult = .idle
        performSubmit(nickname)
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

    func performDuplicateCheck(for nickname: Nickname, checkID: UUID) {
        Task {
            let isAvailable: Bool
            do {
                isAvailable = try await authRepository.checkNicknameDuplicate(nickname: nickname)
            } catch {
                isAvailable = false
            }
            guard nicknameCheckID == checkID else { return }
            nicknameCheckID = nil
            state.validationState = isAvailable ? .available : .duplicate
        }
    }

    func performSubmit(_ nickname: Nickname) {
        Task {
            do {
                switch config {
                case .signup:
                    break // 회원가입 API는 PreferredArtistSettingView에서 호출
                case .update:
                    try await userRepository.updateNickname(nickname)
                }
                state.submittedNickname = nickname
                state.isSubmitting = false
                state.submitResult = .success
            } catch {
                state.isSubmitting = false
                state.submitResult = .failure(DisplayErrorMessage.message(for: error))
            }
        }
    }
}
