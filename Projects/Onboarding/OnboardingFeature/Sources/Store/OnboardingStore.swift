//
//  OnboardingStore.swift
//  OnboardingFeature
//
//  Created by 김진웅 on 11/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct OnboardingState {
    var isTermsAgreed: Bool = false
    var isMarketingAgreed: Bool = false
    
    var isAllAgreed: Bool { isTermsAgreed && isMarketingAgreed }
    var isNextButtonEnabled: Bool { isTermsAgreed }
}

enum OnboardingIntent {
    case toggleAllTermsAgreement
    case toggleTermsAgreement
    case toggleMarketingAgreement
}

@MainActor
final class OnboardingStore: ObservableObject {
    @Published private(set) var state = OnboardingState()
    
    func send(_ intent: OnboardingIntent) {
        switch intent {
        case .toggleAllTermsAgreement:
            let newValue = !state.isAllAgreed
            state.isTermsAgreed = newValue
            state.isMarketingAgreed = newValue
            
        case .toggleTermsAgreement:
            state.isTermsAgreed.toggle()
            
        case .toggleMarketingAgreement:
            state.isMarketingAgreed.toggle()
        }
    }
}
