//
//  OnboardingStore.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/5/25.
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

struct OnboardingState {
    var isTermsAgreed: Bool = false
    var isMarketingAgreed: Bool = false
    
    var nickname: String = ""
    var nicknameValidationState: NicknameValidationState = .idle
}

enum OnboardingIntent {
    case toggleAllTermsAgreement
    case toggleTermsAgreement
    case toggleMarketingAgreement
    
    case updateNickname(String)
    case checkNicknameDuplicate
    case _setNicknameValidationState(NicknameValidationState)
}

@MainActor
final class OnboardingStore: ObservableObject {
    @Published private(set) var state = OnboardingState()
    
    func send(_ intent: OnboardingIntent) {
        switch intent {
        case .toggleAllTermsAgreement:
            let newValue = !(state.isTermsAgreed && state.isMarketingAgreed)
            state.isTermsAgreed = newValue
            state.isMarketingAgreed = newValue
            
        case .toggleTermsAgreement:
            state.isTermsAgreed.toggle()
            
        case .toggleMarketingAgreement:
            state.isMarketingAgreed.toggle()
            
        case .updateNickname(let nickname):
            state.nickname = nickname
            validateNicknameFormat()
            
        case .checkNicknameDuplicate:
            checkNicknameDuplicate()
            
        case ._setNicknameValidationState(let validationState):
            state.nicknameValidationState = validationState
        }
    }
}

private extension OnboardingStore {
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
        guard state.nicknameValidationState == .valid else { return }
        
        send(._setNicknameValidationState(.checking))
        
        // TODO: 실제 API 호출로 대체
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            let isDuplicate = state.nickname == "test"
            send(._setNicknameValidationState(isDuplicate ? .duplicate : .available))
        }
    }
}
