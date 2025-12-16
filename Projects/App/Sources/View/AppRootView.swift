//
//  AppRootView.swift
//  Livith-iOS
//
//  Created by 김진웅 on 12/13/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LoginFeature
import LivithNetwork
import Persistence

struct AppRootView: View {
    @State private var currentRoute: AppRoute?
    @State private var isLaunchScreenVisible: Bool = true
    
    private let localKeyValueStorage: LocalKeyValueStorage
    
    init(localKeyValueStorage: LocalKeyValueStorage = UserDefaultsStorage()) {
        self.localKeyValueStorage = localKeyValueStorage
    }
    
    var body: some View {
        ZStack {
            contentView()
            splashOverlay()
        }
        .animation(.easeInOut(duration: Constants.animationDuration), value: isLaunchScreenVisible)
        .animation(.easeInOut(duration: Constants.animationDuration), value: currentRoute)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.reloginRequired)) { _ in
            currentRoute = .login
        }
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
                LoginRootView {
                    withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                        currentRoute = .main
                    }
                }
            case .main:
                LivithMainTabView()
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
            let _: DTO.Response.FetchUserInfo = try localKeyValueStorage.fetch(for: "currentUser")
            currentRoute = .main
        } catch {
            currentRoute = .login
        }
    }
}

// MARK: - Constants

private extension AppRootView {
    enum Constants {
        static let animationDuration = 0.5
    }
}
