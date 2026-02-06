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

struct AppRootView: View {
    @State private var currentRoute: AppRoute = .launch
    @State private var nickname: String = ""
    @State private var showWelcomeSheet: Bool = false
    
    @Injected private var userRepository: UserRepository
    
    var body: some View {
        contentView
            .crossDissolve(isPresented: $showWelcomeSheet, dismissOnTapOutside: false) {
                LivithModal(
                    type: .welcome(nickname: nickname),
                    onConfirm: { showWelcomeSheet = false }
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.reloginRequired)) { notification in
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
        if currentRoute != .launch { return }
        
        let targetRoute: AppRoute
        do {
            let _: User = try UserDefaultsStorage().fetch(for: .currentUser)
            targetRoute = .main

            preloadUserData()
        } catch {
            targetRoute = .login
        }

        Task {
            try? await Task.sleep(nanoseconds: UInt64(Constants.startupDelay * 1_000_000_000))
            await MainActor.run { transition(to: targetRoute) }
        }
    }
    
    func transition(to route: AppRoute) {
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            currentRoute = route
        }
    }
    
    func preloadUserData() {
        Task {
            async let userFetch = try? userRepository.fetchUser()
            async let concertFetch = try? userRepository.fetchInterestedConcert()
            _ = await (userFetch, concertFetch)
        }
    }
}

// MARK: - Constants

private extension AppRootView {
    enum Constants {
        static let animationDuration = 0.5
        static let startupDelay: TimeInterval = 3.0
    }
}
