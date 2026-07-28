//
//  LoginCoordinatorView.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct LoginCoordinatorView: View {
    @StateObject private var router: LoginRouter

    public init(
        onLoginCompleted: @escaping () -> Void,
        onSignupCompleted: @escaping (String) -> Void
    ) {
        _router = StateObject(
            wrappedValue: LoginRouter(
                onLoginCompleted: onLoginCompleted,
                onSignupCompleted: onSignupCompleted
            )
        )
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            LoginView()
                .navigationDestination(for: LoginRoute.self) { route in
                    destinationView(for: route)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        .environmentObject(router)
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func destinationView(for route: LoginRoute) -> some View {
        switch route {
        case .login:
            LoginView()
        case .terms(let tempUser):
            TermsView(tempUser: tempUser)
        case .nickname(let builder):
            NicknameSettingView(builder: builder)
        case .preferredGenre(let builder):
            PreferredGenreSettingView(builder: builder)
        case .preferredArtist(let builder):
            PreferredArtistSettingView(builder: builder)
        }
    }
}
