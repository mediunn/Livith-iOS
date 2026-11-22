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
import HomeFeature
import Persistence
import DIContainer
import LivithNetworking
import NicknameEditFeature

struct AppRootView: View {
    private let concertRequestRepository: any ConcertRequestRepository

    @State private var currentRoute: AppRoute = .launch
    @State private var sessionNickname: SessionNickname? = nil
    @State private var showWelcomeSheet: Bool = false
    
    @Injected private var tokenManager: TokenManager

    init(concertRequestRepository: any ConcertRequestRepository) {
        self.concertRequestRepository = concertRequestRepository
    }
    
    var body: some View {
        contentView
            .crossDissolve(isPresented: $showWelcomeSheet, dismissOnTapOutside: false) {
                if let nickname = sessionNickname?.nickname {
                    LivithModal(
                        type: .welcome(nickname: nickname),
                        onConfirm: { showWelcomeSheet = false }
                    )
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("reloginRequired"))) { notification in
                transition(to: .login)
            }
            .onReceive(NotificationCenter.default.publisher(for: NotificationService.fcmTokenDidChange)) { _ in
                guard currentRoute == .main else { return }
                NotificationService.shared.registerFCMTokenToServer()
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
            LoginCoordinatorView(
                onLoginCompleted: { transition(to: .main) },
                onSignupCompleted: { nickname in
                    transition(to: .main, initialNickname: nickname)
                    showWelcomeSheet = true
                }
            )
        case .main:
            if let sessionNickname {
                LivithMainTabView(sessionNickname: sessionNickname)
                    .environment(\.concertRequestRepository, concertRequestRepository)
            }
        }
    }
    
    func handleOnAppear() {
        guard currentRoute == .launch else { return }
        
        Task {
            async let minimumDisplay: Void = sleepMinimumDisplayDuration()
            let nextRoute = await resolveLaunchRoute()
            await minimumDisplay
            await MainActor.run {
                guard currentRoute == .launch else { return }
                transition(to: nextRoute)
                if nextRoute == .main {
                    NotificationService.shared.registerFCMTokenToServer()
                }
            }
        }
    }
    
    func sleepMinimumDisplayDuration() async {
        try? await Task.sleep(for: .seconds(Constants.minimumDisplayDuration))
    }
    
    func resolveLaunchRoute() async -> AppRoute {
        UserDefaultsStorage().remove(for: .currentUser)
        do {
            try await tokenManager.refresh()
            return .main
        } catch {
            return .login
        }
    }
    
    func transition(to route: AppRoute, initialNickname: String? = nil) {
        if route == .main {
            if sessionNickname == nil {
                sessionNickname = SessionNickname(nickname: initialNickname)
            }
        } else {
            sessionNickname = nil
            showWelcomeSheet = false
        }
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            currentRoute = route
        }
    }
}

// MARK: - Constants

private extension AppRootView {
    enum Constants {
        static let minimumDisplayDuration = 1
        static let animationDuration = 0.5
    }
}
