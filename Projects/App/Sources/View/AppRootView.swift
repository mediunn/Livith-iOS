//
//  AppRootView.swift
//  Livith-iOS
//
//  Created by 김진웅 on 12/13/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem
import LoginFeature
import LivithNetwork
import Persistence

struct AppRootView: View {
    @State private var currentRoute: AppRoute?
    @State private var isLaunchScreenVisible: Bool = true
    @State private var nickname: String = ""
    @State private var isWelcomeSheetVisible: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    private let localStorage: UserDefaultsStorage
    
    init(localStorage: UserDefaultsStorage = UserDefaultsStorage(defaults: UserDefaults(suiteName: UserDefaultsStorage.appGroupID) ?? .standard)) {
        self.localStorage = localStorage
    }
    
    var body: some View {
        ZStack {
            contentView()
            splashOverlay()
            welcomeSheetOverlay()
        }
        .animation(.easeInOut(duration: Constants.animationDuration), value: isLaunchScreenVisible)
        .animation(.easeInOut(duration: Constants.animationDuration), value: currentRoute)
        .animation(.easeInOut(duration: Constants.animationDuration), value: isWelcomeSheetVisible)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.reloginRequired)) { notification in
            if let message = notification.userInfo?["toastMessage"] as? String {
                toastMessage = message
                transition(to: .login)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showToast = true
                }
            } else {
                transition(to: .login)
            }
        }
        .livithToast(isPresented: $showToast, type: .success, message: toastMessage, position: .safeAreaTop)
        .onAppear {
            handleOnAppear()
        }
    }
}

// MARK: - Helpers

private extension AppRootView {
    @ViewBuilder
    func contentView() -> some View {
        if let route = currentRoute {
            switch route {
            case .login:
                LoginContentView(
                    onLoginCompleted: { nickname in
                        handleLoginCompleted(nickname: nickname)
                    },
                    onSignupCompleted: { nickname in
                        handleSignupCompleted(nickname: nickname)
                    }
                )

            case .main:
                LivithMainTabView(nickname: $nickname)
            }
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    func splashOverlay() -> some View {
        if isLaunchScreenVisible {
            LaunchScreenView()
                .transition(.opacity)
                .zIndex(1)
        }
    }

    @ViewBuilder
    func welcomeSheetOverlay() -> some View {
        if isWelcomeSheetVisible {
            LivithModal(
                type: .welcome(nickname: nickname),
                onConfirm: {
                    withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                        isWelcomeSheetVisible = false
                    }
                }
            )
            .transition(.opacity)
            .zIndex(2)
        }
    }
    
    func handleLoginCompleted(nickname: String) {
        transition(to: .main, nickname: nickname)
    }
    
    func handleSignupCompleted(nickname: String) {
        transition(to: .main, nickname: nickname, showWelcome: true)
    }

    func handleOnAppear() {
        checkInitialRoute()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                isLaunchScreenVisible = false
            }
        }
    }

    func checkInitialRoute() {
        do {
            let user: DTO.Response.FetchUserInfo = try localStorage.fetch(for: .currentUser)
            self.nickname = user.nickname
            currentRoute = .main
        } catch {
            currentRoute = .login
        }
    }

    func transition(to route: AppRoute, nickname: String? = nil, showWelcome: Bool = false) {
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            currentRoute = route

            if let nickname = nickname {
                self.nickname = nickname
            }

            isWelcomeSheetVisible = showWelcome
        }
    }
}

// MARK: - Constants

private extension AppRootView {
    enum Constants {
        static let animationDuration = 0.5
    }
}
