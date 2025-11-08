//
//  TermsStore.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct TermsState {
    var isTermsAgreed: Bool = false
    var isMarketingAgreed: Bool = false
}

enum TermsIntent {
    case toggleAllTermsAgreement
    case toggleTermsAgreement
    case toggleMarketingAgreement
}

@MainActor
final class TermsStore: ObservableObject {
    @Published private(set) var state = TermsState()
    
    func send(_ intent: TermsIntent) {
        switch intent {
        case .toggleAllTermsAgreement:
            let newValue = !(state.isTermsAgreed && state.isMarketingAgreed)
            state.isTermsAgreed = newValue
            state.isMarketingAgreed = newValue
            
        case .toggleTermsAgreement:
            state.isTermsAgreed.toggle()
            
        case .toggleMarketingAgreement:
            state.isMarketingAgreed.toggle()
        }
    }
}
