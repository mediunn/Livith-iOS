//
//  AppRootView.swift
//  Livith-iOS
//
//  Created by 김진웅 on 12/13/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import Domain
import LoginFeature
import Persistence
import DIContainer
import LivithNetworking

struct AppRootView: View {
    @State private var currentRoute: AppRoute = .launch
    @State private var nickname: String = ""
    @State private var showWelcomeSheet: Bool = false
    
    @Injected private var userRepository: UserRepository
    @Injected private var tokenManager: TokenManager
    
    var body: some View {
        contentView
            .crossDissolve(isPresented: $showWelcomeSheet, dismissOnTapOutside: false) {
                LivithModal(
                    type: .welcome(nickname: nickname),
                    onConfirm: { showWelcomeSheet = false }
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("reloginRequired"))) { notification in
                transition(to: .login)
            }
            .onAppear {
                handleOnAppear()
            }
    }
}

// MARK: - Helpers

private extension AppRootView {
    @ViewBuilder
    var contentView: some View {
        switch currentRoute {
        case .launch:
            LaunchScreenView()
        case .login:
            LoginContentView(
                onLoginCompleted: { transition(to: .main) },
                onSignupCompleted: { nickname in
                    self.nickname = nickname
                    transition(to: .main)
                    self.showWelcomeSheet = true
                }
            )
        case .main:
            LivithMainTabView()
        }
    }
    
    func handleOnAppear() {
        guard currentRoute == .launch else { return }
        
        Task {
            guard fetchLocalUser() != nil else {
                try? await tokenManager.remove()
                await MainActor.run { transition(to: .login) }
                return
            }
            
            do {
                try await tokenManager.refresh()
                _ = try? await userRepository.fetchUser()
                await MainActor.run { transition(to: .main) }
            } catch {
                await MainActor.run { transition(to: .login) }
            }
        }
    }
    
    func fetchLocalUser() -> User? {
        try? UserDefaultsStorage().fetch(for: .currentUser)
    }
    
    func transition(to route: AppRoute) {
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            currentRoute = route
        }
    }
}

// MARK: - Constants

private extension AppRootView {
    enum Constants {
        static let animationDuration = 0.5
    }
}
