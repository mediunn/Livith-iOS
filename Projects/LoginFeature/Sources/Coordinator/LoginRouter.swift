//
//  LoginRouter.swift
//  LoginFeature
//
//  Created by on 6/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Coordinator

final class LoginRouter: Router<LoginRoute> {
    private let onLoginCompleted: () -> Void
    private let onSignupCompleted: (String) -> Void

    init(
        onLoginCompleted: @escaping () -> Void = {},
        onSignupCompleted: @escaping (String) -> Void = { _ in }
    ) {
        self.onLoginCompleted = onLoginCompleted
        self.onSignupCompleted = onSignupCompleted
        super.init()
    }

    func completeLogin() {
        onLoginCompleted()
    }

    func completeSignup(with nickname: String) {
        onSignupCompleted(nickname)
    }
}
