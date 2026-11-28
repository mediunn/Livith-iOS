//
//  TermsStore.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct TermsState {
    var isTermsAgreed: Bool = false
    var isPrivacyAgreed: Bool = false
    var isMarketingAgreed: Bool = false
}

enum TermsIntent {
    case toggleAllTermsAgreement
    case toggleTermsAgreement
    case togglePrivacyAgreement
    case toggleMarketingAgreement
}

final class TermsStore: ObservableObject {
    @Published private(set) var state = TermsState()

    private var isAllAgreed: Bool {
        state.isTermsAgreed && state.isPrivacyAgreed && state.isMarketingAgreed
    }

    func send(_ intent: TermsIntent) {
        switch intent {
        case .toggleAllTermsAgreement:
            let newValue = !isAllAgreed
            state.isTermsAgreed = newValue
            state.isPrivacyAgreed = newValue
            state.isMarketingAgreed = newValue

        case .toggleTermsAgreement:
            state.isTermsAgreed.toggle()

        case .togglePrivacyAgreement:
            state.isPrivacyAgreed.toggle()

        case .toggleMarketingAgreement:
            state.isMarketingAgreed.toggle()
        }
    }
}
