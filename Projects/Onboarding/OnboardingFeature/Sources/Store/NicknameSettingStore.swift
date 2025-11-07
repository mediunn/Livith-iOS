//
//  NicknameSettingStore.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

enum NicknameValidationState {
	case idle
	case valid
	case invalid
	case checking
	case available
	case duplicate
}

struct NicknameSettingState {
	var nickname: String = ""
	var nicknameValidationState: NicknameValidationState = .idle
}

enum NicknameSettingIntent {
	case updateNickname(String)
	case checkNicknameDuplicate
	case _setNicknameValidationState(NicknameValidationState)
}

@MainActor
final class NicknameSettingStore: ObservableObject {
	@Published private(set) var state = NicknameSettingState()

	func send(_ intent: NicknameSettingIntent) {
		switch intent {
		case .updateNickname(let nickname):
			state.nickname = nickname
			validateNicknameFormat()
            
		case .checkNicknameDuplicate:
			state.nicknameValidationState = .checking
			checkNicknameDuplicate()
            
		case ._setNicknameValidationState(let validationState):
			state.nicknameValidationState = validationState
		}
	}
}

// MARK: - Helper

private extension NicknameSettingStore {
	func validateNicknameFormat() {
		guard !state.nickname.isEmpty else {
			send(._setNicknameValidationState(.idle))
			return
		}
		let pattern = "^[a-zA-Z0-9가-힣]{1,10}$"
		let isValid = state.nickname.range(of: pattern, options: .regularExpression) != nil
		send(._setNicknameValidationState(isValid ? .valid : .invalid))
	}

	func checkNicknameDuplicate() {
		// TODO: 실제 API 호출로 대체
		Task {
			try? await Task.sleep(for: .seconds(1))
			let isDuplicate = state.nickname == "test"
			send(._setNicknameValidationState(isDuplicate ? .duplicate : .available))
		}
	}
}
